xquery version "3.1" encoding "UTF-8";

(:~
 : roaster OpenAPI router entry point. Routes requests according to api.json,
 : resolving each operationId to a function in modules/rest.xqm.
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace roaster = "http://e-editiones.org/roaster";
import module namespace api = "http://betamasaheft.eu/Dillmann/api" at "rest.xqm";

declare function local:lookup($name as xs:string) {
  function-lookup(xs:QName($name), 1)
};

roaster:route(("api.json"), local:lookup#1)
