xquery version "3.1" encoding "UTF-8";
import module namespace fusekisparql = 'https://www.betamasaheft.uni-hamburg.de/gez-en/sparqlfuseki' at "fuseki.xqm";
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";

declare namespace t = "http://www.tei-c.org/ns/1.0";

(:Tittel  Bermudez sabel Chiarcos :)
let $operation := 'INSERT'
let $data := collection('/db/apps/parser/traces')//t:fs[@type = 'graphunit']

for $annotation in $data
let $annoID := 'traces:' || string($annotation/@xml:id)
let $morph := for $m in $annotation//t:fs[@type = "morpho"]/t:f[not(@name = 'lex')]
return
    string($m/@name) || ' ' || $m/text()
let $tokens := if ($annotation//t:fs[@type = 'tokens']) then
    (
    for $token in $annotation//t:fs[@type = 'tokens']/t:f[@name = 'lit']
    let $tokenURI := string($annotation/@xml:id) || '_' || string($token/position())
    let $morphtok := for $m in $token//t:fs[@type = "morpho"]/t:f[not(@name = 'lex')]
    return
        string($m/@name) || ' ' || $m/text()
    return
        $annoID || ' traces:hasToken traces:' || $tokenURI || ' .
        traces:' || $tokenURI || ' a traces:Token ;
        rdfs:comment "' || string-join($morphtok, ' - ') || '" ;
        rdfs:seeAlso dillmann:' || substring-before($token//t:f[@name = "lex"]/text(), '--') || ' .'
    )
else
    $annoID || ' rdfs:comment "' || string-join($morph, ' - ') || '" ;
rdfs:seeAlso dillmann:' || substring-before($annotation//t:f[@name = "lex"]/text(), '--') || ' .'

let $query :=  $annoID || ' a oa:Annotation ;
        oa:hasTarget bm:' || string($annotation/ancestor::t:TEI/@corresp) || ' ;
        rdfs:label "' || $annotation//t:f[@name = "fidäl"]/text() || '"@gez ;
        rdfs:label "' || $annotation//t:f[@name = "translit"]/text() || '"@gez-trsl . 
        
        '
|| string-join($tokens, '
')


return
(:    $query:)
    fusekisparql:update('traces', $operation, $query)