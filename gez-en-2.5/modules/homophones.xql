xquery version "3.1" encoding "UTF-8";

declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace s = "http://www.w3.org/2005/xpath-functions";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
import module namespace app="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en" at "app.xql";

let $letter := ''
let $starts-with := if($letter) then ('[starts-with(.,"' || $letter || '")]') else ()
    let $data-collection := '/db/apps/gez-en/data'
    let $collection := collection($data-collection)
    let $translations := $collection//t:cit[@type='translation']
let $query:= '$translations/t:quote' || $starts-with
    let $trans := for $word at $p in util:eval($query)
            let $trimmedword := replace(replace($word,'\s+$',''),'^\s+','')
            let $root := root($word)//t:entry/@xml:id
            group by $t := $trimmedword
            order by $t
            
                return 
                     map {"hit" := $t,
                         "roots" := for $r in $root 
                            return string($r)
                     }
    return 
        map {'hits' := $trans}
