xquery version "3.0" encoding "UTF-8";

import module namespace console = "http://exist-db.org/xquery/console";

import module namespace log="http://www.betamasaheft.eu/log" at "../modules/log.xqm";
declare namespace t = "http://www.tei-c.org/ns/1.0";

declare namespace l = "http://log.log";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $id := request:get-parameter("id", "")

let $data-collection := '/db/apps/gez-en/data/'
let $doc := collection($data-collection)//id($id)
let $form := $doc//t:form/t:foreign/text()
let $user := sm:id()//sm:username/text()

   let $log := log:add-log-message('/Dillmann/lemma/'||$id, $user, 'delete confirmation requested')
return
<html>
    <head>
        <title>Delete Confirmation</title>
          
                <link
                    rel="shortcut icon"
                    href="resources/images/favicon.ico"/>
                <meta
                    name="viewport"
                    content="width=device-width, initial-scale=1.0"/>
                <link
                    rel="shortcut icon"
                    href="resources/images/minilogo.ico"/>
                <link
                    rel="stylesheet"
                    type="text/css"
                    href="$shared/resources/css/bootstrap-3.0.3.min.css"/>
                <link
                    rel="stylesheet"
                    href="resources/font-awesome-4.7.0/css/font-awesome.min.css"/>
                <link
                    rel="stylesheet"
                    type="text/css"
                    href="resources/css/style.css"/>
                <script
                    type="text/javascript"
                    src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
                <script
                    type="text/javascript"
                    src="https://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
                <script
                    type="text/javascript"
                    src="https://cdn.jsdelivr.net/jquery.slick/1.6.0/slick.min.js"></script>
                <script
                    type="text/javascript"
                    src="resources/scripts/loadsource.js"></script>
                <script
                    type="text/javascript"
                    src="$shared/resources/scripts/bootstrap-3.0.3.min.js"></script>
                    
                
    </head>
    <body>
     <div class="col-md-4 col-md-offset-4">   
    <h1 style="text-align: center; ">Are you really sure you want to delete <strong>{$form}</strong>?</h1>
    <div id="Lid"  style="display: none;">{$id}</div>
    <div id="user"  style="display: none;">{$user}</div>
    <div class="form-check">
    <input type="checkbox" class="form-check-input" id="notifyEditors"/>
    <label class="form-check-label" for="notifyEditors">Send an email to the editors about this change</label>
  </div>
  <div id="choice">
        <a role="button" style="margin-bottom:4px; word-wrap:break-word; white-space:normal;" class="col-md-6 btn btn-danger" id="confirmDelete" >Yes. Delete it with no mercy (but make a backup).</a>
        <a  role="button" style="margin-botto:4px; word-wrap:break-word; white-space:normal;" class="col-md-6 btn btn-success" id="abortDelete" >No!!! I hit the red trash button by mistake! Take me back...</a>
   </div>
   </div>
   <script type="application/javascript" src="resources/js/delete.js"/>
   </body>
</html>