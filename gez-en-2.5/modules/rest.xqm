xquery version "3.1"  encoding "UTF-8";


module namespace api="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/api";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";

import module namespace fusekisparql = 'https://www.betamasaheft.uni-hamburg.de/BetMas/sparqlfuseki' at "fuseki.xqm";


(: For interacting with the TEI document :)

declare namespace tei = "http://www.tei-c.org/ns/1.0";
(: For REST annotations :)
declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace http = "http://expath.org/ns/http-client";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace json="http://www.json.org";
(: For output annotations  :)

 declare
%rest:GET
%rest:path("/BetMas/api/Dillmann/SPARQL")
%rest:query-param("query", "{$query}", "")
%output:method("xml")
function apisparql:sparqlQuery($query as xs:string*) {

let $q := ((if(starts-with($query, 'PREFIX')) then () else $apisparql:prefixes) || normalize-space($query))  
let $xml := fusekisparql:query('dillmann', $q)
return
($apisparql:response200XML,
$xml
)};

declare
%rest:GET
%rest:path("/BetMas/api/Dillmann/rootmembers/{$id}")
%output:method("json")
function api:rootmembers($id as xs:string){
let $sparqlquery := $config:sparqlPrefixes || "
SELECT ?sequence ?id ?text ?root
WHERE
{
?entry rdf:member 	dillmann:"||$id||"_comp ;
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
let $fusekicall := fusekisparql:query('dillmann', $sparqlquery)

         let $requested := $fusekicall//sr:literal[.= $id]
         let $thisResult := $requested/ancestor::sr:result
         let $thisN := xs:integer($thisResult//sr:binding[@name='sequence']/sr:literal)
         let $prevs := for $p in $fusekicall//sr:result[xs:integer(sr:binding[@name='sequence']/sr:literal) lt $thisN]
                             let $id := $p/sr:binding[@name='id']/sr:literal/text()
                             let $entriesN := $p/sr:binding[@name='sequence']/sr:literal/text()
                             let $pr := $p/sr:binding[@name='root']/sr:literal/text()
                             let $lem := $p/sr:binding[@name='text']/sr:literal/text()
                              return
                              map {'id': $id, 'n': $entriesN, 'role' : $pr, 'lem' : $lem}
       let $nexts := for $p in $fusekicall//sr:result[xs:integer(sr:binding[@name='sequence']/sr:literal) gt $thisN]
                          let $id := $p/sr:binding[@name='id']/sr:literal/text()
                          let $entriesN := $p/sr:binding[@name='sequence']/sr:literal/text()
                          let $pr := $p/sr:binding[@name='root']/sr:literal/text()
                          let $lem := $p/sr:binding[@name='text']/sr:literal/text()
                           return
                             map {'id': $id, 'n': $entriesN, 'role' : $pr, 'lem' : $lem}
return
(
$config:response200Json,
 map {'here': map {  'id': $id, 
                                'n': xs:integer($thisResult/sr:binding[@name='sequence']/sr:literal/text()), 
                                'role' : $thisResult/sr:binding[@name='root']/sr:literal/text(), 
                                'lem' : $thisResult/sr:binding[@name='text']/sr:literal/text()
                                } , 
          'prev' : $prevs, 
          'next' : $nexts}
  )

};




(:                   searches Dillmann lexicon:)
declare
%rest:GET
%rest:path("/BetMas/api/Dillmann/search/{$element}")
%rest:query-param("q", "{$q}", "")
%output:method("json")
function api:searchDillmann($element as xs:string?,
$q as xs:string*) {
    if($q ='') then () else
    let $login := xmldb:login('/db/apps/BetMas/data', 'Pietro', 'Hdt7.10')
    let $data-collection := '/db/apps/DillmannData'

    let $eval-string := concat("$config:collection-root//tei:"
    , $element, "[ft:query(*,'", $q, "')]")
    let $hits := for $hit in util:eval($eval-string) order by ft:score($hit) descending return $hit
    return
        if (count($hits) gt 0) then
            ($config:response200Json,
            <json:value>
                {
                    for $hit in $hits
                    let $id := $hit/ancestor::tei:TEI//tei:entry/@xml:id

                    return
                        <json:value
                            json:array="true">
                            <id>{string($id)}</id>
                            {element {xs:QName($element)} {normalize-space(string-join($hit//text(), ' '))}}

                        </json:value>
                }
            </json:value>)
        else
            ($config:response200Json,
            <json:value>
                <json:value
                    json:array="true">
                    <id>0</id>
                    <action>1</action>
                    <info>No results, sorry</info>
                    <start>1</start>
                </json:value>
            </json:value>)
};



declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/list/xml")
    %rest:query-param("start", "{$start}", 1)
    %output:method("xml")
function api:getListofLemmas($lemma as xs:string?, $start as xs:integer*){
($config:response200Json,
    let $hits := for $hit in  $config:collection-root//tei:entry
     order by xs:integer($hit/@n)
     return $hit
     let $total := count($hits)
     return
     <list>
     <lemmas>{

   for $lem in subsequence($hits, $start, 20)
   return
<lemma><id>{string($lem/@xml:id)}</id><n>{string($lem/@n)}</n><form>{string($lem//tei:form)}</form></lemma>
   }</lemmas>
   <total>{$total}</total>
   <current>{$start}-{($start+20)-1}</current>
{                if ($total > $start) then
                    (<next>
                        {$start + 20}-{($start + 40) - 1}
                    </next>,
                    if ($start > 20) then
                        <prev>
                            {$start - 20}-{$start - 1}
                        </prev>
                    else
                        ())
                else
                    ()}
   </list>
  )
                   };

declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/list/json")
    %rest:query-param("start", "{$start}", 1)
    %output:method("json")
function api:getListofLemmasJ($lemma as xs:string?, $start as xs:integer*){
($config:response200Json,

    let $hits := for $hit in  $config:collection-root//tei:entry
     order by xs:integer($hit/@n)
     return $hit
     let $total := count($hits)
     return
     <json:value>{

   for $lem in subsequence($hits, $start, 20)
   return
<lemmas><id>{string($lem/@xml:id)}</id><n>{string($lem/@n)}</n><lemma>{normalize-space(string($lem//tei:form))}</lemma></lemmas>
   }
   <total>{$total}</total>
   <current>{$start}-{($start+20)-1}</current>
{                if ($total > $start) then
                    (<next>
                        {$start + 20}-{($start + 40) - 1}
                    </next>,
                    if ($start > 20) then
                        <prev>
                            {$start - 20}-{$start - 1}
                        </prev>
                    else
                        ())
                else
                    ()}
   </json:value>
  )
                   };

declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/{$lemma}/teientry")
    %output:method("xml")
function api:getLemma($lemma as xs:string?){

let $item := root( $config:collection-root//id($lemma))
return
if(exists($item)) then
($config:response200XML,
    let $data-collection := '/db/apps/DillmannData/'
   return
    $config:collection-root//id($lemma)
  ) else ($config:response400, <info>{$lemma || 'is not a lemma unique id of any entry.'}</info>

  )
                   };

declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/{$lemma}/json")
    %output:method("json")
function api:getLemmaJson($lemma as xs:string?){


let $item :=  $config:collection-root//id($lemma)
return
if(exists($item)) then
($config:response200Json,
   $item
  )
  else
  ($config:response400, map{'info' := ($lemma || 'is not a lemma unique id of any entry.')}
  )
                   };

declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/{$lemma}/txt")
    %output:method("text")
function api:getLemmaTXT($lemma as xs:string?){


let $item := root( $config:collection-root//id($lemma))//tei:TEI
return
if(exists($item)) then
($config:response200,
   transform:transform($item, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())
  ) else ($config:response400, $lemma || 'is not a lemma unique id of any entry.')
                   };


(:get 1000 to 1000 the all as txt :)
declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/all/txt")
    %rest:query-param("start", "{$start}", 1)
    %rest:query-param("total", "{$total}", 1000)
    %output:method("text")
function api:getHugeTXT($start as xs:integer*,$total as xs:integer*){
($config:response200,

let $filecontent := for $d in subsequence( $config:collection-root//tei:entry[starts-with(@xml:id, 'L')], $start, $total)
               order by $d/@n
                return
                  transform:transform($d, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())
 return string-join($filecontent, ' &#13;'))
};


 declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/number/{$n}")
    %output:method("json")
function api:getLemmaNumber($n as xs:string?){
($config:response200Json,

let $match :=  $config:collection-root//tei:entry[@n = $n]
let $entry := string($match/@xml:id)
return
map {
  'number' : $n,
  'lemma' : $entry
  })
                   };


(:format of $n must be c0000:)
 declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/column/{$n}")
    %output:method("json")
function api:getLemmaColumn($n as xs:string?){
($config:response200Json,

let $match :=  $config:collection-root//id($n)
let $entry := string(root($match)//tei:entry/@xml:id)
return
map {
  'column' : $n,
  'lemma' : $entry
  })
                   };


 declare
    %rest:GET
    %rest:path("/BetMas/api/Dillmann/otherlemmas")

%rest:query-param("lemma", "{$lemma}", "")
    %output:method("json")
function api:getsamelemma($lemma as xs:string*){
($config:response200Json,
 let $eval-string :=
      concat(" $config:collection-root//tei:form/tei:foreign[ft:query(.,'", $lemma, "')]")
 let $hits :=
           for $hit in util:eval($eval-string)
           order by ft:score($hit) descending
           return $hit
 let $response :=
          if(count($hits) ge 1) then  for $hit in $hits
          let $hitID := string(root($hit)//tei:entry/@xml:id)
          return map {
  'id' : $hitID,
  'hit' : $hit/text()
  }
          else 'this is all new!'

return
map {
  'response' : $response,
  'total' : count($hits)
  })
                   };
