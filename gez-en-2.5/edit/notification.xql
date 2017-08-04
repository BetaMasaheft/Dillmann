xquery version "3.0" encoding "UTF-8";
import module namespace console = "http://exist-db.org/xquery/console";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
let $data := request:get-data()

let $diff := request:get-parameter('diff', ())
let $user := request:get-parameter('user', ())
let $id := request:get-parameter('id', ())
let $filename := request:get-parameter('filename', ())
let $msg := request:get-parameter('msg', ())
let $html := util:parse-html($diff)

let $EditorialBoardMessage := <mail>
    <from>pietro.liuzzo@uni-hamburg.de</from>
    <to>susanne.hummel@uni-hamburg.de</to>
    <to>fonv216@uni-hamburg.de</to>
    <to>vitagrazia.pisani@gmail.com</to>
    <to>wolfgang.dickhut@gmail.com</to>
    <cc>pietro.liuzzo@gmail.com</cc>
    <bcc></bcc>
    <subject>Lexicon Linguae Aethiopicae: {$filename} has been updated</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>This is a summary of the changes made to {$filename} </title>
                 <style>
                 {'ins {background-color:chartreuse}
del {background-color:lightcoral}'}
                 </style>
               </head>
               <body>
                  <p>{$msg}</p>
                   <p>These are the difference visible in the txt output:</p>
                  <div>{$html//BODY/child::node()}</div>
                  <p><a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/lemma/{$id}" 
                  target="_blank">See {$filename} online!</a> There you can also update the file again.</p>
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
  
  