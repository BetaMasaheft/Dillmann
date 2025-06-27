xquery version "3.0" encoding "UTF-8";

declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace l = "http://log.log";

import module namespace log = "http://www.betamasaheft.eu/Dillmann/log" at "../modules/log.xqm";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace sm = "http://exist-db.org/xquery/securitymanager";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $id := request:get-parameter("id", "")

let $data-collection := "/db/apps/gez-en/data/"
let $doc := collection($data-collection)//id($id)
let $form := $doc//t:form/t:foreign/text()
let $user := sm:id()//sm:username/text()

let $log := log:add-log-message(
  "/Dillmann/lemma/" || $id,
  $user,
  "delete confirmation requested"
)
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
      <script src="resources/scripts/loadsource.js" type="text/javascript" />
      <script
        src="resources/scripts/bootstrap-3.0.3.min.js"
        type="text/javascript" />
    </head>
    <body>
      <div class="col-md-4 col-md-offset-4">
        <h1
          style="text-align: center; "
        >Are you really sure you want to delete <strong>{ $form }</strong>?</h1>
        <div id="Lid" style="display: none;">{ $id }</div>
        <div id="user" style="display: none;">{ $user }</div>
        <div class="form-check">
          <input class="form-check-input" id="notifyEditors" type="checkbox" />
          <label
            class="form-check-label"
            for="notifyEditors"
          >Send an email to the editors about this change</label>
        </div>
        <div id="choice">
          <a
            class="col-md-6 btn btn-danger"
            id="confirmDelete"
            role="button"
            style="margin-bottom:4px; word-wrap:break-word; white-space:normal;"
          >Yes. Delete it with no mercy (but make a backup).</a>
          <a
            class="col-md-6 btn btn-success"
            id="abortDelete"
            role="button"
            style="margin-botto:4px; word-wrap:break-word; white-space:normal;"
          >No!!! I hit the red trash button by mistake! Take me back...</a>
        </div>
      </div>
      <script src="resources/js/delete.js" type="application/javascript" />
    </body>
  </html>
