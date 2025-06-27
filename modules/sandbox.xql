xquery version "3.1";

declare namespace t = "http://www.tei-c.org/ns/1.0";

import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";

base-uri($config:collection-root//id("Lef52e4be9d7a4b1087d344152c8d21c6"))
