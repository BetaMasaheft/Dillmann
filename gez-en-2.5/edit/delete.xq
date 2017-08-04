xquery version "3.0" encoding "UTF-8";

import module namespace console = "http://exist-db.org/xquery/console";

declare namespace t = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";


let $cU := xmldb:get-current-user()
let $backup-collection := '/db/apps/gez-en/deleted/'
let $data-collection := '/db/apps/gez-en/data'

(: log into the collection :)
let $login := xmldb:login($data-collection, 'Pietro', 'Hdt7.10')
 
(: get the id parameter from the URL :)

let $id := request:get-parameter('id', '')
let $file := concat($id, '.xml')

let $record := collection($data-collection)//id($id)
let $targetfileuri := base-uri($record)
let $item := doc($targetfileuri)

let $store := xmldb:store($backup-collection, $file, $item)

let $filename := root($record)//t:form/t:foreign/text()


let $sendmails :=(
let $contributorMessage := <mail>
    <from>pietro.liuzzo@uni-hamburg.de</from>
    <to>{sm:get-account-metadata($cU, xs:anyURI('http://axschema.org/contact/email'))}</to>
    <cc></cc>
    <bcc></bcc>
    <subject>Thank you from Lexicon Linguae Aethiopicae for your contribution!</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>You have just deleted {$filename} </title>
               </head>
               <body>
                  <h1>You have just deleted {$filename}</h1>
                  <p>But no worries: we have made a copy in case you did it by mistake.</p>
                  <p>If that is the case, reply to this email and explain what happened, otherways farewell {$filename}!</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
if ( mail:send-email($contributorMessage, 'public.uni-hamburg.de', ()) ) then
  console:log('Sent Message to editor OK')
else
  console:log('message not sent to editor')
  
  ,
  
  let $EditorialBoardMessage := <mail>
    <from>pietro.liuzzo@uni-hamburg.de</from>
    <to>susanne.hummel@uni-hamburg.de</to>
    <to>fonv216@uni-hamburg.de</to><to>vitagrazia.pisani@gmail.com</to><to>wolfgang.dickhut@gmail.com</to>
    <cc></cc>
    <bcc>pietro.liuzzo@gmail.com</bcc>
    <subject>Lexicon Linguae Aethiopicae says: {$filename} has been deleted!</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>{$filename} has been deleted</title>
               </head>
               <body>
                  <h1>{$filename} has been deleted!</h1>
                  <p>{$cU} hit the red trash button and confirmed that she/he meant it.</p>
                 <p>But no worries: we have made a copy in case {$cU} did it by mistake.</p>
                  <p>If that is the case, reply to this email and explain what you think might have happened, otherways farewell {$filename}!</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
if ( mail:send-email($EditorialBoardMessage, 'public.uni-hamburg.de', ()) ) then
  console:log('Sent Message to editor OK')
else
  console:log('message not sent to editor')
)

let $filelocation :=  substring-before($targetfileuri, $id)
(: delete the file :)
let $delete := xmldb:remove($filelocation, $file)

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
                    src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
                <script
                    type="text/javascript"
                    src="http://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
                <script
                    type="text/javascript"
                    src="http://cdn.jsdelivr.net/jquery.slick/1.6.0/slick.min.js"></script>
                <script
                    type="text/javascript"
                    src="$shared/resources/scripts/loadsource.js"></script>
                <script
                    type="text/javascript"
                    src="$shared/resources/scripts/bootstrap-3.0.3.min.js"></script>
                    
                
    </head>
    <body>
     <div class="col-md-4 col-md-offset-4"  style="text-align: center; ">   
    <h1> Farewell !</h1>
       <p class="lead">A backup copy has been made, you and the editors have been emailed.</p>
       <a role="button" href="/Dillmann/" class="btn btn-info">Home</a>
       </div>
   </body>
</html>