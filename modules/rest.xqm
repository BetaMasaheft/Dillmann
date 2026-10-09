xquery version "3.1" encoding "UTF-8";

module namespace api = "http://betamasaheft.eu/Dillmann/api";

(: For interacting with the TEI document :)

declare namespace sr = "http://www.w3.org/2005/sparql-results#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json = "http://www.json.org";

import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "xmldb:exist:///db/apps/gez-en/modules/config.xqm";
import module namespace fusekisparql = "https://www.betamasaheft.uni-hamburg.de/gez-en/sparqlfuseki" at "xmldb:exist:///db/apps/gez-en/modules/fuseki.xqm";
import module namespace roaster = "http://e-editiones.org/roaster";

declare function api:sparqlQuery($request as map(*)) {
	let $query as xs:string* := $request?parameters?query
	let $q := (
		(
			if (starts-with($query, "PREFIX")) then (
			) else
				$config:sparqlPrefixes
		) ||
			normalize-space($query)
	)
	let $xml := fusekisparql:query("dillmann", $q)
	return $xml
};

declare function api:rootmembers($request as map(*)) {
	let $id as xs:string := $request?parameters?id
	let $sparqlquery := $config:sparqlPrefixes ||
		"
SELECT ?sequence ?id ?text ?root
WHERE
{ dillmann:lexicon lexicog:entry ?entry .
?entry rdf:member 	dillmann:" ||
		$id ||
		"_comp ;
 ?prop ?member .
  ?member lexicog:describes ?entryorsense .
  dillmann:lexicon ?rdfsequence ?entryorsense .
  ?entryorsense ontolex:lexicalForm ?form .
  ?form ontolex:writtenRep ?text .

  FILTER (STRSTARTS(STR(?rdfsequence), 'http://www.w3.org/1999/02/22-rdf-syntax-ns#_'))
BIND (xsd:integer(STRAFTER(STR(?rdfsequence), 'http://www.w3.org/1999/02/22-rdf-syntax-ns#_')) as ?sequence)
BIND (STRBEFORE(STRAFTER(STR(?entry),'https://betamasaheft.eu/Dillmann/'), '_entry') as ?rootid)
BIND (STRAFTER(STR(?entryorsense),'https://betamasaheft.eu/Dillmann/') as ?id)
  BIND(IF(CONTAINS(STR(?entryorsense), ?rootid), 'currentRoot', 'member' ) as ?root)
}
ORDER BY ?sequence"
	let $fusekicall := fusekisparql:query("dillmann", $sparqlquery)

	let $requested := $fusekicall//sr:literal[. = $id]
	let $thisResult := $requested/ancestor::sr:result
	let $thisN := xs:integer($thisResult//sr:binding[@name = "sequence"]/sr:literal)
	let $prevs :=
		for $p in $fusekicall//sr:result[xs:integer(sr:binding[@name = "sequence"]/sr:literal) lt $thisN]
		let $id := $p/sr:binding[@name = "id"]/sr:literal/text()
		let $entriesN := $p/sr:binding[@name = "sequence"]/sr:literal/text()
		let $pr := $p/sr:binding[@name = "root"]/sr:literal/text()
		let $lem := $p/sr:binding[@name = "text"]/sr:literal/text()
		return map {"id": $id, "n": $entriesN, "role": $pr, "lem": $lem}
	let $nexts :=
		for $p in $fusekicall//sr:result[xs:integer(sr:binding[@name = "sequence"]/sr:literal) gt $thisN]
		let $id := $p/sr:binding[@name = "id"]/sr:literal/text()
		let $entriesN := $p/sr:binding[@name = "sequence"]/sr:literal/text()
		let $pr := $p/sr:binding[@name = "root"]/sr:literal/text()
		let $lem := $p/sr:binding[@name = "text"]/sr:literal/text()
		return map {"id": $id, "n": $entriesN, "role": $pr, "lem": $lem}
	return map {
		"here":
			map {
				"id": $id,
				"n": xs:integer($thisResult/sr:binding[@name = "sequence"]/sr:literal/text()),
				"role": $thisResult/sr:binding[@name = "root"]/sr:literal/text(),
				"lem": $thisResult/sr:binding[@name = "text"]/sr:literal/text()
			},
		"prev": $prevs,
		"next": $nexts
	}
};

(: searches Dillmann lexicon :)
declare function api:searchDillmann($request as map(*)) {
	let $element as xs:string? := $request?parameters?element
	let $q as xs:string* := $request?parameters?q
	return if (empty($q) or $q = "") then (
	) else
		let $data-collection := "/db/apps/DillmannData"
		let $cleanQ := replace(string-join($q, ""), '([\\+\-\!\(\)\{\}\[\]\^"~\*\?:\/])', "\\$1")
		let $hits := try {
			for $hit in
				$config:collection-root//*[local-name() = $element and
					namespace-uri() = "http://www.tei-c.org/ns/1.0"][ft:query(*, $cleanQ)]
			order by ft:score($hit) descending
			return $hit
		} catch * { () }
		return if (count($hits) gt 0) then (
			<json:value>
				{
					for $hit in $hits
					let $id := $hit/ancestor::tei:TEI//tei:entry/@xml:id

					return <json:value json:array="true">
						<id>{ string($id) }</id>
						{ element {xs:QName($element)} { normalize-space(string-join($hit//text(), " ")) } }
					</json:value>
				}
			</json:value>
		) else (
			<json:value>
				<json:value json:array="true">
					<id>0</id>
					<action>1</action>
					<info>No results, sorry</info>
					<start>1</start>
				</json:value>
			</json:value>
		)
};

declare function api:getListofLemmas($request as map(*)) {
	let $start as xs:integer* := $request?parameters?start
	let $hits :=
		for $hit in $config:collection-root//tei:entry
		order by xs:integer($hit/@n)
		return $hit
	let $total := count($hits)
	return <list>
		<lemmas>
			{
				for $lem in subsequence($hits, $start, 20)
				return <lemma>
					<id>{ string($lem/@xml:id) }</id>
					<n>{ string($lem/@n) }</n>
					<form>{ string($lem//tei:form) }</form>
				</lemma>
			}
		</lemmas>
		<total>{ $total }</total>
		<current>{ $start }-{ ($start + 20) - 1 }</current>
		{
			if ($total > $start) then (
				<next>{ $start + 20 }-{ ($start + 40) - 1 }</next>,
				if ($start > 20) then
					<prev>{ $start - 20 }-{ $start - 1 }</prev>
				else (
				)
			) else (
			)
		}
	</list>
};

declare function api:getListofLemmasJ($request as map(*)) {
	let $start as xs:integer* := $request?parameters?start
	let $hits :=
		for $hit in $config:collection-root//tei:entry
		order by xs:integer($hit/@n)
		return $hit
	let $total := count($hits)
	return <json:value>
		{
			for $lem in subsequence($hits, $start, 20)
			return <lemmas>
				<id>{ string($lem/@xml:id) }</id>
				<n>{ string($lem/@n) }</n>
				<lemma>{ normalize-space(string($lem//tei:form)) }</lemma>
			</lemmas>
		}
		<total>{ $total }</total>
		<current>{ $start }-{ ($start + 20) - 1 }</current>
		{
			if ($total > $start) then (
				<next>{ $start + 20 }-{ ($start + 40) - 1 }</next>,
				if ($start > 20) then
					<prev>{ $start - 20 }-{ $start - 1 }</prev>
				else (
				)
			) else (
			)
		}
	</json:value>
};

declare function api:getLemma($request as map(*)) {
	let $lemma as xs:string? := $request?parameters?lemma
	let $item := root($config:collection-root//id($lemma))
	return if (exists($item)) then
		let $data-collection := "/db/apps/DillmannData/"
		return $config:collection-root//id($lemma)
	else
		roaster:response(400, <info>{ $lemma || "is not a lemma unique id of any entry." }</info>)
};

declare function api:getLemmaJson($request as map(*)) {
	let $lemma as xs:string? := $request?parameters?lemma
	let $item := $config:collection-root//id($lemma)
	return if (exists($item)) then
		$item
	else
		roaster:response(400, map {"info": ($lemma || "is not a lemma unique id of any entry.")})
};

declare function api:getLemmaTXT($request as map(*)) {
	let $lemma as xs:string? := $request?parameters?lemma
	let $item := root($config:collection-root//id($lemma))//tei:TEI
	return if (exists($item)) then
		transform:transform($item, "xmldb:exist:///db/apps/gez-en/xslt/txt.xsl", ())
	else
		roaster:response(400, $lemma || "is not a lemma unique id of any entry.")
};

(: get 1000 to 1000 the all as txt :)
declare function api:getHugeTXT($request as map(*)) {
	let $start as xs:integer* := $request?parameters?start
	let $total as xs:integer* := $request?parameters?total
	let $filecontent :=
		for $d in subsequence($config:collection-root//tei:entry[starts-with(@xml:id, "L")], $start, $total)
		order by $d/@n
		return transform:transform($d, "xmldb:exist:///db/apps/gez-en/xslt/txt.xsl", ())
	return string-join($filecontent, " &#13;")
};

declare function api:getLemmaNumber($request as map(*)) {
	let $n as xs:string? := $request?parameters?n
	let $match := $config:collection-root//tei:entry[@n = $n]
	let $entry := string($match/@xml:id)
	return map {"number": $n, "lemma": $entry}
};

(: format of $n must be c0000 :)
declare function api:getLemmaColumn($request as map(*)) {
	let $n as xs:string? := $request?parameters?n
	let $match := $config:collection-root//id($n)
	let $entry := string(root($match)//tei:entry/@xml:id)
	return map {"column": $n, "lemma": $entry}
};

declare function api:getsamelemma($request as map(*)) {
	let $lemma as xs:string* := $request?parameters?lemma
	let $hits :=
		for $hit in $config:collection-root//tei:form/tei:foreign[ft:query(., $lemma)]
		order by ft:score($hit) descending
		return $hit
	let $response := if (count($hits) ge 1) then
		for $hit in $hits
		let $hitID := string(root($hit)//tei:entry/@xml:id)
		return map {"id": $hitID, "hit": $hit/text()}
	else
		"this is all new!"

	return map {"response": $response, "total": count($hits)}
};
