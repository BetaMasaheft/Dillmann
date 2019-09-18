xquery version "3.1";
import module namespace kwic = "http://exist-db.org/xquery/kwic"    at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
declare namespace t = "http://www.tei-c.org/ns/1.0";

base-uri($config:collection-root//id('Ldc8c69eda00b4756a7a533d684abcdd3'))

