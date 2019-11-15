xquery version "3.1" encoding "UTF-8";
import module namespace fusekisparql = 'https://www.betamasaheft.uni-hamburg.de/BetMas/sparqlfuseki' at "fuseki.xqm";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";

(:https://www.w3.org/2019/09/lexicog/:)
let $data := collection($config:data-root)
let $triplesentry := for $entry in subsequence($data, 1, 10) return transform:transform($entry, 'xmldb:exist:///db/apps/gez-en/xslt/xml2turtle.xsl', ())
let $tripleslexicon := 'dillmann:lexicon a lexicog:LexicographicResource ;
	    dc:language "la" .
	    dillmann:traces a lexicog:LexicographicResource ;
	    dc:language "en" .
	    dillmann:leslau a lexicog:LexicographicResource ;
	    dc:language "en" .
	    '
let $all := ($tripleslexicon || string-join($triplesentry, ' 
'))
let $operation := 'INSERT'
return
fusekisparql:update('dillmann', $operation, $all)