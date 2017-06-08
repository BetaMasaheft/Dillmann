xquery version "3.0" encoding "UTF-8";
import module namespace app="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/dict" at "../modules/app.xql";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace validation = "http://exist-db.org/xquery/validation";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace s = "http://www.w3.org/2005/xpath-functions";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

declare variable $id := request:get-parameter('id', ());

declare variable $form := request:get-parameter('form', ());

let $parametersName := request:get-parameter-names()
let $cU := xmldb:get-current-user()
let $msg := request:get-parameter('msg', ())
let $title := 'Update Confirmation'
let $data-collection := '/db/apps/dict/data'
let $record := collection($data-collection)//id($id)
let $rootitem := root($record)//tei:TEI
let $backup-collection := '/db/apps/dict/EditorBackups/'
let $targetfileuri := base-uri($record)
let $filename := $record//tei:form/tei:foreign/text()

(:saves a copy of the file before editing in a backup folder in order to be able to mechanically restore in case of editing errors since no actual versioning is in place.:)
let $backupfilename := ($id||'BACKUP'||format-dateTime(current-dateTime(), "[Y,4][M,2][D,2][H01][m01][s01]")||'.xml')
let $item := doc($targetfileuri)
let $store := xmldb:store($backup-collection, $backupfilename, $item)

return
if(contains($parametersName, 'sense')) then (
let $eachsense := <senses>{for $parm in $parametersName
return
if(starts-with($parm, 'sense')) then(
let $couple := <couple><sense>{request:get-parameter($parm,())}</sense><source>{request:get-parameter(('source' || substring-after($parm, 'sense')),())}</source></couple>
return
app:upconvertSense($couple)
)
else()}</senses>



let $temporary := 
(:let $form := $record//tei:form//tei:foreign//text()
return:)
<TEI xmlns="http://www.tei-c.org/ns/1.0"
            xml:lang="la">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title
                            xml:lang="gez">{$form}</title>
                       <author>Alessandro Bausi</author>
                <author>Andreas Ellwardt</author>
                </titleStmt>
                <publicationStmt>
                       <authority>Hiob Ludolf Zentrum für Äthiopistik</authority>
                <publisher>TraCES project.
                                    https://www.traces.uni-hamburg.de/</publisher>
                <pubPlace>Hamburg</pubPlace>
                <availability>
                    <licence target="http://creativecommons.org/licenses/by-sa-nc/4.0/">
                                        This file is licensed under the Creative Commons
                                        Attribution-ShareAlike Non Commercial 4.0. </licence>
                </availability>
            </publicationStmt>
            <sourceDesc>
                <p>A thoroughly elaborated txt version of <ref xml:id="dillmann"
                  target="https://archive.org/details/lexiconlinguaeae00dilluoft">Dillmann,
                  Christian Friedrich August. <emph>Lexicon linguae aethiopicae, cum indice latino.
                     Adiectum est vocabularium tigre dialecti septentrionalis compilatum</emph> a W.
                  Munziger. Lipsiae: Th.O. Weigel, 1865.</ref>
            </p>
            <p><ref xml:id="traces" target="https://www.traces.uni-hamburg.de/">ERC Advanced Grant
                  TraCES (Grant Agreement 338756)</ref></p>
            </sourceDesc>
                
                </fileDesc>
               
        <encodingDesc>
            <p>A digital edition of the Lexicon in TEI.</p>
        </encodingDesc>
                <profileDesc>
                    
                    <langUsage>
                         <language ident="en">English</language>
                <language ident="la">latin</language>
                <language ident="it">Italian</language>
                <language ident="gez">Gǝʿǝz</language>
                <language ident="grc">Ancient Greek</language>
                <language ident="syr">Syriac</language>
                <language ident="ar">Arabic</language>
                <language ident="sa">Sanskrit</language>
                <language ident="geo">Georgian</language>
                <language ident="cop">Coptic</language>
                <language ident="osa">Old South Arabian</language>
                    </langUsage>
                </profileDesc>
                <revisionDesc>
                    <change
                        who="AppValidationTemporaryFile"
                        when="{format-date(current-date(), "[Y0001]-[M01]-[D01]")}">{$msg}</change>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <div>
                <entry>
                    <form>
                        <foreign xml:lang="gez">{$form}</foreign>
                    </form>
                    {for $s in $eachsense//tei:sense[@xml:lang][@source] return $s}
                </entry>
                </div>
               </body>
            </text>
        </TEI>

let $schema := doc('/db/apps/dict/schema/Dillmann.rng')
            let $validation := validation:jing($temporary, $schema)
            return 
            if($validation = true()) then (

let $sensesArray := $item//tei:sense
let $sensesLang := for $lang in $sensesArray/@xml:lang return $lang
let $eachLang := for $lang in $eachsense//tei:sense[@source]/@xml:lang return $lang

let $updateform :=  for $s in $eachsense//tei:sense[@xml:lang][@source]
let $slang := string($s/@xml:lang)

return
if($sensesArray[@xml:lang = $slang]) 
then( update replace $sensesArray[@xml:lang=$slang] with $s)
else (update insert $s into $item//tei:entry)

let $deleteRemoved := for $removedLang in distinct-values($sensesLang[not(.=$eachLang)])
return
    update delete $sensesArray[@xml:lang=$removedLang]


let $change := <change xmlns="http://www.tei-c.org/ns/1.0" who="{switch(xmldb:get-current-user()) case 'Pietro' return 'PL' case 'Vitagrazia' return 'VP' case 'Alessandro' return 'AB' default return 'AE'}" when="{format-date(current-date(), "[Y0001]-[M01]-[D01]")}">{$msg}</change>
let $updateChange := update insert $change into doc($targetfileuri)//tei:revisionDesc
let $updatemainForm := update replace $record//tei:form//tei:foreign//text() with $form

(:nofity editor and contributor:)
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
                 <title>This is a summary of the changes you made to {$filename} </title>
               </head>
               <body>
                  <h1>Thanks for your changes to {$filename}!</h1>
                  <p>This is how the txt version looks like now:</p>
                  <p>{transform:transform($rootitem, 'xmldb:exist:///db/apps/dict/xslt/txt.xsl', ())}</p>
                  <p><a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/lemma/{$id}" 
                  target="_blank">See {$filename} online!</a> There you can also update the file again.</p>
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
    <subject>Lexicon Linguae Aethiopicae says: {$filename} has been updated!</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>Changes in {$filename} on </title>
               </head>
               <body>
                  <h1>There is something new in {$filename}!</h1>
                  <p>{$cU} said she/he: {$msg} in this file</p>
                  <p>This is how it looks like in txt now:</p>
                  <p>{transform:transform($rootitem, 'xmldb:exist:///db/apps/dict/xslt/txt.xsl', ())}</p>
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
)
return
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
                
                <title>Save Confirmation</title>
            </head>
            <body>
<div class="alert alert-success">
    <h2>{$title}</h2>
    <p class="lead">Dear {$cU}, Lemma  <a href="/Dillmann/lemma/{$id}">{$filename}</a> has been updated successfully!</p>
   <p>A notification email has been sent to the editors.</p>
   <p class="lead">Thank you!</p>
  </div>
  </body>
  </html>
  )
  else (
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
                    src="$shared/resources/scripts/loadsource.js"></script>           
                    
                   <script
                    type="text/javascript"
                    src="$shared/resources/scripts/bootstrap-3.0.3.min.js"></script>
                 
                   
                <title>Save Confirmation</title>
                
            </head>
            <body>
  <div class="col-md-12 alert alert-warning">
  
  <p class="lead">Sorry, the document you are trying to save is not valid. 
  There is probably an error in the content somewhere. Below you can see the report from the schema and the XML produced: check it out or send the link or a screenshoot to somebody for help.</p>
                <pre>{validation:jing-report($temporary, $schema)}</pre>
                <div id="editorContainer"><div id="ACEeditor">{$temporary//tei:entry}</div></div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.6/ace.js" type="text/javascript" charset="utf-8"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.6/ext-language_tools.js" type="text/javascript" charset="utf-8"></script>
            
<script src="resources/js/ACEsettings.js"/>  

</div>
</body>
</html>
  )
  
  ) else()