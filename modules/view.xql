xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace templates = "http://exist-db.org/xquery/html-templating";
import module namespace lib = "http://exist-db.org/xquery/html-templating/lib";
(:
 : The following modules provide functions which will be called by the
 : templating.
 :)
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace app = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en" at "app.xql";

declare option output:method "html5";
declare option output:media-type "text/html";

let $config := map {
  $templates:CONFIG_APP_ROOT: $config:app-root,
  $templates:CONFIG_STOP_ON_ERROR: true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function ($functionName as xs:string, $arity as xs:int) {
  try { function-lookup(xs:QName($functionName), $arity) } catch * { () }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return templates:apply($content, $lookup, (), $config)
