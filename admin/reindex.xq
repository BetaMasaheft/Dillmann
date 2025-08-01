xquery version "1.0";

import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $data-collection := "/db/apps/DillmannData"

let $start-time := util:system-time()
let $reindex := xmldb:reindex($data-collection)
let $runtime-ms := (
  (util:system-time() - $start-time) div xs:dayTimeDuration("PT1S")
) *
  1000

return <html>
    <head><title>Reindex</title></head>
    <body>
      <h1>Reindex</h1>
      <p>The index for { $data-collection } was updated in 
                 {
          $runtime-ms
        } milliseconds.</p>
    </body>
  </html>
