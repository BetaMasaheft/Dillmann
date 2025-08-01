xquery version "3.0" encoding "UTF-8";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace util = "http://exist-db.org/xquery/util";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $data := request:get-data()

let $diff := request:get-parameter("diff", ())
let $user := request:get-parameter("user", ())
let $editorsnotification := request:get-parameter("notifyEditors", ())
let $id := request:get-parameter("id", ())
let $filename := request:get-parameter("filename", ())
let $msg := request:get-parameter("msg", ())
let $html := util:parse-html($diff)

let $EditorialBoardMessage := <mail>
  <from>pietro.liuzzo@uni-hamburg.de</from>
  {
    if ($editorsnotification = "yes") then (
      <to>andreas.ellwardt@uni-hamburg.de</to>,
      <to>susanne.hummel@uni-hamburg.de</to>,
      <to>wolfgang.dickhut@uni-hamburg.de</to>,
      <to>vitagrazia.pisani@gmail.com</to>,
      <to>magdalena.krzyzanowska-2@uni-hamburg.de</to>
    ) else (
    )
  }
  <to>pietro.liuzzo@gmail.com</to>
  <bcc />
  <subject>Lexicon Linguae Aethiopicae: { $filename } has been updated</subject>
  <message>
    <xhtml>
      <html>
        <head>
          <title>This is a summary of the changes made to { $filename }</title>
          <style>
            {
              "ins {background-color:chartreuse}
del {background-color:lightcoral}"
            }
          </style>
        </head>
        <body>
          <p>{ $msg }</p>
          <p>These are the difference visible in the txt output:</p>
          <div>{ $html//BODY/child::node() }</div>
          <p>
            <a
              href="https://betamasaheft.eu/Dillmann/lemma/{ $id }"
              target="_blank"
            >See {
                $filename
              } online!</a> There you can also update the file again.</p>
        </body>
      </html>
    </xhtml>
  </message>
</mail>

return (: if ( mail:send-email($EditorialBoardMessage, 'public.uni-hamburg.de', ()) ) then
  util:log("info", 'Sent Message to editor OK')
else :) util:log("info", "message not sent to editor")
