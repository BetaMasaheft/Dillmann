xquery version "3.0" encoding "UTF-8";

declare namespace t = "http://www.tei-c.org/ns/1.0";

import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "../modules/config.xqm";
import module namespace updatefuseki = "https://www.betamasaheft.uni-hamburg.de/BetMas/updatefuseki" at "../modules/updateFuseki.xqm";
import module namespace log = "http://www.betamasaheft.eu/Dillmann/log" at "../modules/log.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace sm = "http://exist-db.org/xquery/securitymanager";
import module namespace mail = "http://exist-db.org/xquery/mail";
import module namespace util = "http://exist-db.org/xquery/util";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $cU := sm:id()
let $backup-collection := "/db/apps/gez-en/deleted/"
let $data-collection := "/db/apps/DillmannData"

(: get the id parameter from the URL :)
let $editorsnotification := request:get-parameter("notifyEditors", "")
let $id := request:get-parameter("id", "")
let $user := request:get-parameter("user", "")
let $file := concat($id, ".xml")

let $record := $config:collection-root//id($id)
let $targetfileuri := base-uri($record)
let $item := doc($targetfileuri)

let $store := xmldb:store($backup-collection, $file, $item)
let $log := log:add-log-message($id, $user, "backup")
let $filename := root($record)//t:form/t:foreign/text()

let $sendmails := (
  let $contributorMessage := <mail>
    <from>pietro.liuzzo@uni-hamburg.de</from>
    <to>
      {
        sm:get-account-metadata(
          $cU,
          xs:anyURI("http://axschema.org/contact/email")
        )
      }
    </to>
    <cc />
    <bcc />
    <subject
    >Thank you from Lexicon Linguae Aethiopicae for your contribution!</subject>
    <message>
      <xhtml>
        <html>
          <head><title>You have just deleted { $filename }</title></head>
          <body>
            <h1>You have just deleted { $filename }</h1>
            <p
            >But no worries: we have made a copy in case you did it by mistake.</p>
            <p
            >If that is the case, reply to this email and explain what happened, otherways farewell {
                $filename
              }!</p>
          </body>
        </html>
      </xhtml>
    </message>
  </mail>
  return if (
      mail:send-email($contributorMessage, "public.uni-hamburg.de", ())
    ) then
      util:log("info", "Sent Message to editor OK")
    else
      util:log("info", "message not sent to editor"),
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
    <subject>Lexicon Linguae Aethiopicae says: {
        $filename
      } has been deleted!</subject>
    <message>
      <xhtml>
        <html>
          <head><title>{ $filename } has been deleted</title></head>
          <body>
            <h1>{ $filename } has been deleted!</h1>
            <p>
              {
                $cU
              } hit the red trash button and confirmed that she/he meant it.</p>
            <p>But no worries: we have made a copy in case {
                $cU
              } did it by mistake.</p>
            <p
            >If that is the case, reply to this email and explain what you think might have happened, otherways farewell {
                $filename
              }!</p>
          </body>
        </html>
      </xhtml>
    </message>
  </mail>
  return if (
      mail:send-email($EditorialBoardMessage, "public.uni-hamburg.de", ())
    ) then
      util:log("info", "Sent Message to editor OK")
    else
      util:log("info", "message not sent to editor")
)

let $filelocation := substring-before($targetfileuri, $id)
(: delete the file :)
let $delete := xmldb:remove($filelocation, $file)

let $updateFuseki := updatefuseki:entry($record, "DELETE")

let $log := log:add-log-message($id, $user, "deleted")
return <html>
    <head>
      <title>Delete Confirmation</title>
      <link href="resources/images/favicon.ico" rel="shortcut icon" />
      <meta content="width=device-width, initial-scale=1.0" name="viewport" />
      <link href="resources/images/minilogo.ico" rel="shortcut icon" />
      <link
        href="resources/css/bootstrap-3.0.3.min.css"
        rel="stylesheet"
        type="text/css" />
      <link
        href="resources/font-awesome-4.7.0/css/font-awesome.min.css"
        rel="stylesheet" />
      <link href="resources/css/style.css" rel="stylesheet" type="text/css" />
      <script
        src="https://code.jquery.com/jquery-1.11.0.min.js"
        type="text/javascript" />
      <script
        src="https://code.jquery.com/jquery-migrate-1.2.1.min.js"
        type="text/javascript" />
      <script
        src="https://cdn.jsdelivr.net/jquery.slick/1.6.0/slick.min.js"
        type="text/javascript" />
      <script
        src="resources/scripts/bootstrap-3.0.3.min.js"
        type="text/javascript" />
    </head>
    <body>
      <div class="col-md-4 col-md-offset-4" style="text-align: center; ">
        <h1> Farewell !</h1>
        <p
          class="lead"
        >A backup copy has been made, you and the editors have been emailed.</p>
        <a class="btn btn-info" href="/Dillmann/" role="button">Home</a>
      </div>
    </body>
  </html>
