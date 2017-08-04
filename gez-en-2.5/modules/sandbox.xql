xquery version "3.1";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";
for $x in collection($config:data-root)//tei:sense[@n='l']
return base-uri($x)