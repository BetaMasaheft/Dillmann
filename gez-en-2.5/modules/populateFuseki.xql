xquery version "3.1" encoding "UTF-8";

import module namespace fusekisparql = 'https://www.betamasaheft.uni-hamburg.de/BetMas/sparqlfuseki' at "fuseki.xqm";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";

declare namespace t="http://www.tei-c.org/ns/1.0";

(:https://www.w3.org/2019/09/lexicog/:)

(:takes 1 parent URI and a sequence of nested senses:)
declare function local:sense($parentURI as xs:string, $sense){
let $parentURI_comp := $parentURI || '_comp' 
let $nested := for $s in $sense 
              let $senseURI := $parentURI || '_sense_' ||string($s/@xml:id)
              return local:sense($senseURI, $s/t:sense)
let $nestedLexical := for $s in $sense 
              let $senseURI := $parentURI || '_sense_' ||string($s/@xml:id)
              return $senseURI || ' a ontolex:LexicalSense  . 
              '
let $components := for $s in $sense 
              let $senseURI := $parentURI || '_sense_' ||string($s/@xml:id) 
              let $senseURI_comp := $senseURI || '_comp'
              return $senseURI_comp || ' a lexicog:LexicographicComponent . 
              '
let $describes :=          for $s in $sense 
              let $senseURI := $parentURI || '_sense_' ||string($s/@xml:id) 
              let $senseURI_comp := $senseURI || '_comp'
              return $senseURI_comp || ' lexicog:describes ' || $senseURI || ' .
              '
let $rdfSeq :=  
              for $s at $p in $sense
              let $senseURI := $parentURI || '_sense_' ||string($s/@xml:id)
              let $senseURI_comp := $senseURI || '_comp'
                             return 
	   'rdf:_'||$p||' '|| $senseURI_comp
let $rdfSeqStatement := $parentURI_comp || ' ' || string-join($rdfSeq, '; 
') || ' .
'	   
return
($rdfSeqStatement
,$nested,
$components,
$nestedLexical,
$describes)
};


let $tripleslexicon := '
dillmann:lexicon a lexicog:LexicographicResource ;
                    a lime:Lexicon ;
                    lime:language "gez" ; # not sure if this should be different, this is the language about which the lexicon is
	    dc:language "la" . # this is the language in which the lexicon is written
	    dillmann:traces a lexicog:LexicographicResource ;
	    dc:language "en" .
	    dillmann:leslau a lexicog:LexicographicResource ;
	    dc:language "en" .
	    '

let $data := collection($config:data-root) 
(:looks for the roots and orders them, so that the next one is the next root:)
let $lexicogEntries := for $lexicogentry in $data//t:rs[@type='root'] order by number($lexicogentry/ancestor::t:entry/@n) return $lexicogentry/ancestor::t:entry
(:takes all the non roots, so that they can be grabbed by looking at @n:)
let $limeEntry := $data//t:entry[not(descendant::t:rs[@type='root'])]

let $triplesentry := 
                for $root in subsequence($lexicogEntries, 1, 10) 
                   let $entryURI := concat('dillmann:',string($root/@xml:id))
                   let $entryN := $root/@n
                   let $entryIndex := index-of($lexicogEntries, $lexicogEntries[@n = $entryN])
                   let $NextEntryN := $lexicogEntries[$entryIndex +1]/@n
                   let $rootentries := $limeEntry[xs:integer(@n) ge xs:integer($entryN)][xs:integer(@n) lt xs:integer($NextEntryN)]
                   let $rootentriescount := count($rootentries)
                   let $rootmembers := for $member in $rootentries return concat('dillmann:',string($member/@xml:id), '_comp')
                   let $components := for $comp in $rootmembers 
                                                            return  $comp || ' a lexicog:LexicographicComponent ;
                                                             lexicog:describes '||replace($comp, '_comp', '')||' .'
                    let $limentries := for $member in $rootentries return '
                                                         dillmann:lexicon lime:entry dillmann:'||string($member/@xml:id) || ' ;
                                                         rdf:_'||string($entryN)||' dillmann:'||string($member/@xml:id) || ' . #added, not in document, to represent the general sequence of entries.
                                                         dillmann:'||string($member/@xml:id) ||  ' a ontolex:LexicalEntry .'
                   let $senses := local:sense($entryURI,$root/t:sense) 
                                                         
                                                         
(:                   roots are both lexicog and lime entries, while non roots are only lime entries.:)
                return 
           'dillmann:lexicon lexicog:entry  '||$entryURI|| '_entry ;
                                              rdf:_'||string($entryIndex)||' '||$entryURI ||'_entry . #added, not in documentation, to sequence the roots in dillmann
            '|| $entryURI || '_entry a lexicog:Entry ;
                                             '|| (if($rootentriescount ge 1) then ( 'rdf:member ' || string-join($rootmembers, ', ') || ' .') else ())||  '
                                             '  ||string-join( $components, '
                   ') ||string-join( $limentries, '
                   ') || '
                   '||string-join($senses, '
                   ')
                                   
let $lexicon := for $entry in subsequence(($lexicogEntries, $limeEntry), 1,10) 
                    let $entryURI := concat('dillmann:',string($entry/@xml:id))
                    return
$entryURI || '_form a ontolex:Form ;
       ontolex:writtenRep "'||normalize-space(string-join($entry/t:form//text())) ||'"@gez .

   '||$entryURI||' ontolex:lexicalForm  '||$entryURI||'_form .'

(:        ontolex:sense :animal_n_sense_1 ;
        ontolex:sense :animal_n_sense_2 . '
:)	
let $all := ($tripleslexicon || 
string-join($triplesentry, ' 
' )||string-join($lexicon, ' 
'))

let $test := 'dillmann:L6267cc5bb7fc4bc1b80b5568aa2f67d6 ontolex:lexicalForm  dillmann:L6267cc5bb7fc4bc1b80b5568aa2f67d6_form . 
dillmann:Le069e393d9794e098b17a382d5254382_form a ontolex:Form ;
       ontolex:writtenRep "ሆህያት"@gez .'
       
let $operation := 'INSERT'
return
(:$all:)
fusekisparql:update('dillmann', $operation, $all)