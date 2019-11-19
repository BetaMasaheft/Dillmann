xquery version "3.1";

declare namespace t = "http://www.tei-c.org/ns/1.0";

let $data := collection('/db/apps/data')
for $sense in $data//t:sense[@n]
let $mainSense := $sense/ancestor::t:sense[@source]
let $parentSense := for $pS in $sense/ancestor::t:sense[@n] let $position := count($pS/ancestor::t:sense) order by $position return string($pS/@n)
let $newId := substring($mainSense/@xml:id,1,1) || string-join($parentSense) || string($sense/@n)

let $update := update insert attribute xml:id {$newId} into $sense
return
  'updated ' || base-uri($sense) || ' sense ' || string($sense/@n)  || ' with xml:id ' || $newId
