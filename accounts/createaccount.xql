xquery version "3.0" encoding "UTF-8";
import module namespace console = "http://exist-db.org/xquery/console";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $email := request:get-parameter('email', ())
let $name := request:get-parameter('name', ())
let $user := request:get-parameter('usr', ())
let $pass := request:get-parameter('psw', ())
let $create := sm:create-account($user, $pass, 'Cataloguers', string($name), 'collaborator')
let $addmail := sm:set-account-metadata($user, xs:anyURI('http://axschema.org/contact/email'), $email)
let $sendnotification :=
let $newuserMessage := <mail>
    <from>pietro.liuzzo@uni-hamburg.de</from>
    <to>{$email}</to>
    <bcc>pietro.liuzzo@gmail.com</bcc>
    <subject>Welcome to Lexicon Linguae Aethiopicae {$name}. Your account has been created!</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>Your account on Lexicon Linguae Aethiopicae</title>
                
               </head>
               <body>
                  <h1>Welcome {$name}!</h1>
                  <p>Your new account is</p>
                  <p>UN: {$user}</p>
                  <p>PW: {$pass}</p>
                  
                  <p>Thanks for creating an account on <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/" 
                  target="_blank">Lexicon Linguae Aethiopicae</a> </p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
if ( mail:send-email($newuserMessage, 'public.uni-hamburg.de', ()) ) then
  console:log('Sent Message to new user OK')
else
  console:log('message not sent to new user')


return
if (sm:user-exists($user)) then
<html>
            
            <head>
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
                    href="resources/css/bootstrap-3.0.3.min.css"/>
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
                    src="resources/scripts/loadsource.js"></script>
                <script
                    type="text/javascript"
                    src="resources/scripts/bootstrap-3.0.3.min.js"></script>
                
                <title>Save Confirmation</title>
                <style>
                
                </style>
            </head>
            <body>
<div class="alert alert-success">
    <h2>Account Creation</h2>
    
   <p class="lead">Thank you! An email with your password has been sent to you.</p>
   
   <a href="/Dillmann/">Go back to main page and login.</a>
  </div>
  </body>
  </html>
  else <html>
            
            <head>
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
                    href="resources/css/bootstrap-3.0.3.min.css"/>
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
                    src="resources/scripts/loadsource.js"></script>
                <script
                    type="text/javascript"
                    src="resources/scripts/bootstrap-3.0.3.min.js"></script>
                
                <title>Save Confirmation</title>
                <style>
                
                </style>
            </head>
            <body>
<div class="alert alert-warning">
    <h2>Account Creation</h2>
    
   <p class="lead">Sorry. An account could not be created.</p>
   
   <a href="/Dillmann/">Go back to main page.</a>
  </div>
  </body>
  </html>