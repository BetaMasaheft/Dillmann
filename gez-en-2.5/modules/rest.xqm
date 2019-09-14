xquery version "3.1"  encoding "UTF-8";


module namespace api="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/api";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";



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
%rest:path("/BetMas/api/Dillmann/rootmembers/{$id}")
%output:method("json")
function api:rootmembers($id as xs:string){
   
let $col :=  $config:collection-root
let $term := $col//id($id)
let $lem := let $terms := $term//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms
let $n := xs:integer($term/@n)
let $cr := if($term//tei:rs[@type='root']) then 'currentRoot' else 'member'
    let $allroots := $col//tei:rs[@type='root']
let $nextroots := $allroots/ancestor::tei:entry[xs:integer(@n) gt $n]
let $minN :=  xs:integer(min($nextroots/@n))
let $nextroot := $nextroots[@n = $minN]
let $nextrootid := $nextroot/@xml:id/string()

let $prevroots := $allroots/ancestor::tei:entry[xs:integer(@n) lt $n]
let $maxN :=  xs:integer(max($prevroots/@n))
let $prevroot := $prevroots[@n = $maxN]
let $prevrootid := $prevroot/@xml:id/string()
let $nexts :=
    for $entriesN at $p in ($n + 1) to $minN
    let $ent := $col//tei:entry[xs:integer(@n) = $entriesN]
    let $lem := let $terms := $ent//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms

    let $id := string($ent/@xml:id)
    let $nr := if($ent//tei:rs[@type='root']) then 'nextRoot' else 'member'
    order by $p
    return
        map {'id': $id, 'n': $entriesN, 'role' : $nr, 'lem' : $lem}
let $prevs :=
 for $entriesN at $p in $maxN to ($n -1)
    let $ent := $col//tei:entry[xs:integer(@n) = $entriesN]
    let $lem := let $terms := $ent//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms
     let $id := string($ent/@xml:id)
    let $pr := if($ent//tei:rs[@type='root']) then 'prevRoot' else 'member'
    order by $p
    return
         map {'id': $id, 'n': $entriesN, 'role' : $pr, 'lem' : $lem}
return 
    ($config:response200Json,
    map {'here': map {'id': $id, 'n': xs:integer($n), 'role' : $cr, 'lem' : $lem} , 'prev' : $prevs, 'next' : $nexts})
    
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
    let $data-collection := '/db/apps/gez-en/data'
    
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
    let $data-collection := '/db/apps/gez-en/data/'
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
                  