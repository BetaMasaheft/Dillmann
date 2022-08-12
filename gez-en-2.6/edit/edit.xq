xquery version "3.0" encoding "UTF-8";
import module namespace app="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en" at "../modules/app.xql";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "../modules/config.xqm";
import module namespace updatefuseki = 'https://www.betamasaheft.uni-hamburg.de/gez-en/updatefuseki' at "../modules/updateFuseki.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace validation = "http://exist-db.org/xquery/validation";

import module namespace log="http://www.betamasaheft.eu/log" at "../modules/log.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace s = "http://www.w3.org/2005/xpath-functions";

declare namespace l = "http://log.log";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

declare variable $id := request:get-parameter('id', ());
declare variable $notifyEditors := request:get-parameter('notifyEditors', ());
declare variable $root := request:get-parameter('root', ());
declare variable $form := request:get-parameter('form', ());
declare variable $formlang := request:get-parameter('formlang', ());

declare function local:mergeMain($a, $b  as item()*  )  as item()* {
    if (empty($a) and empty ($b)) 
    then ()
    else if (empty ($b) or $a[1] lt $b[1])
    then (<div style="width: 50%; float: left;" class="left">{$a[1]//text()}</div>, local:mergeMain(subsequence($a, 2), $b))
    else if (empty ($a) or $a[1] gt $b[1])
    then  (<div style="width: 50%; margin-left:50%;" class="right">{$b[1]//text()}</div>,local:mergeMain($a, subsequence($b,2)))  
    else  (<div style="width: 100%; text-align: center;" class="match" >{$a[1]//text()}</div>,  local:mergeMain(subsequence($a,2), subsequence($b,2)))
  };
  
  declare function local:mergeDeep($a, $b  as item()*  )  as item()* {
    if (empty($a) and empty ($b)) 
    then ()
    else if (empty ($b) or $a[1] lt $b[1])
    then (<span style="color: red;">{$a[1]}</span>, local:mergeDeep(subsequence($a, 2), $b))
    else if (empty ($a) or $a[1] gt $b[1])
    then  (<span style="color: green;">{$b[1]}</span>,local:mergeDeep($a, subsequence($b,2)))  
    else  (<span>{$a[1]}</span>,  local:mergeDeep(subsequence($a,2), subsequence($b,2)))
  };
  
let $parametersName := request:get-parameter-names()
let $cU := sm:id()//sm:real/sm:username/string()
let $msg := request:get-parameter('msg', ())
let $title := 'Update Confirmation'
let $record := $config:collection-root//id($id)

let $rootitem := root($record)//tei:TEI
let $backup-collection := xmldb:encode-uri('/db/apps/gez-en/EditorBackups/')
let $targetfileuri := base-uri($record)
let $filename := $record//tei:form/tei:foreign/text()

(:saves a copy of the file before editing in a backup folder in order to be able to mechanically restore in case of editing errors since no actual versioning is in place.:)
let $backupfilename := ($id||'BACKUP'||format-dateTime(current-dateTime(), "[Y,4][M,2][D,2][H01][m01][s01]")||'.xml')
let $item := doc($targetfileuri)
let $store := xmldb:store($backup-collection, $backupfilename, $item)

let $log := log:add-log-message($backupfilename, sm:id()//sm:real/sm:username/string(), 'backup')
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
                            xml:lang="{$formlang}">{$form}</title>
                       <author>Alessandro Bausi</author>
                </titleStmt>
                <publicationStmt>
                       <authority>Hiob-Ludolf-Zentrum für Äthiopistik</authority>
                <publisher>TraCES project.
                                    https://www.traces.uni-hamburg.de/</publisher>
                <pubPlace>Hamburg</pubPlace>
                <availability>
                    <licence target="https://creativecommons.org/licenses/by-sa-nc/4.0/">
                                        This file is licensed under the Creative Commons
                                        Attribution-ShareAlike Non Commercial 4.0. </licence>
                </availability>
            </publicationStmt>
            <sourceDesc>
                <p>A thoroughly elaborated txt version of <ref xml:id="dillmann"
                  target="https://archive.org/details/lexiconlinguaeae00dilluoft">Dillmann,
                  Christian Friedrich August. <emph>Lexicon linguae aethiopicae, cum indice latino.
                     Adiectum est vocabularium tigre dialecti septentrionalis compilatum</emph> a W.
                  Munziger. Lipsiae: Th.O. Weigel, 1865</ref>
            </p>
            <p><ref xml:id="traces" target="https://www.traces.uni-hamburg.de/">ERC Advanced Grant
                  TraCES (Grant Agreement 338756) and follow-up projects</ref></p>
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
                    <form>{if($root='root') then <rs type="root"/> else ()}
                        <foreign xml:lang="{$formlang}">{$form}</foreign>
                    </form>
                    {for $s in $eachsense//tei:sense[@xml:lang][@source] return $s}
                </entry>
                </div>
               </body>
            </text>
        </TEI>

let $schema := doc('/db/apps/gez-en/schema/Dillmann.rng')
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

(:the senses without id should have been updated and the id can be injected into them, the main sense is instead already in the upconversion step:)
let $addxmlids := for $sensewithoutid in $sensesArray//tei:sense[@n]
                            let $mainSense := $sensewithoutid/ancestor::tei:sense[@source]
                            let $parentSense := for $pS in $sensewithoutid/ancestor::tei:sense[@n] 
                                                            let $position := count($pS/ancestor::tei:sense) 
                                                            order by $position 
                                                            return string($pS/@n)
                            let $newId := substring($mainSense/@xml:id,1,1) || string-join($parentSense) || string($sensewithoutid/@n)
                            return 
                                      update insert attribute xml:id {$newId} into $sensewithoutid

let $segRoot := <rs xmlns="http://www.tei-c.org/ns/1.0" type="root"/>
let $change := <change xmlns="http://www.tei-c.org/ns/1.0" who="{switch(sm:id()//sm:real/sm:username/string()) case 'Pietro' return 'PL' case 'Vitagrazia' return 'VP' case 'Alessandro' return 'AB' case 'Magda' return 'MK' case 'Daria' return 'DE' case 'Susanne' return 'SH' case 'Wolfgang' return 'WD' case 'Maria' return 'MB' case 'Andreas' return 'AE' case 'LeonardBahr' return 'LB' case 'Ralph' return 'RL' case 'Jeremy' return 'JB' case 'Joshua' return 'JF'  default return 'AB'}" when="{format-date(current-date(), "[Y0001]-[M01]-[D01]")}">{$msg}</change>
let $updateChange := update insert $change into doc($targetfileuri)//tei:revisionDesc
let $addroot := if($root='root' and $record//tei:form[not(descendant::tei:rs[@type='root'])]) then update insert $segRoot into doc($targetfileuri)//tei:form else ()
let $updatemainForm := update replace $record//tei:form//tei:foreign//text() with $form

let $updateFuseki := try{updatefuseki:entry($record, 'INSERT')} catch * {console:log('failed to update fuseki')}

let $log := log:add-log-message($id, sm:id()//sm:real/sm:username/string(), 'updated')
(:this section produces the diffs. it does not yet recurse the content for a deeper deep although there is a local function ready to do that:)
let $backupedfile := doc(concat($backup-collection, '/',  $backupfilename))
let $diff := local:mergeMain($backupedfile//tei:entry/*, $rootitem//tei:entry/*)

(:nofity editor and contributor:)
let $sendmails := if($cU = 'Andreas') then () else
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
                 <style>
                 {'.left {background-color: red;}
                 .right {background-color: green;}'}
                 </style>
               </head>
               <body>
                  <h1>Thanks for your changes to {$filename}!</h1>
                  <p>This is how the txt version looks like now:</p>
                  <p>{transform:transform($rootitem, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</p>
                  <p>These are the areas of difference:</p>
                  <div>{$diff}</div>
                  <p><a href="https://betamasaheft.eu/Dillmann/lemma/{$id}" 
                  target="_blank">See {$filename} online!</a> There you can also update the file again.</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
if ( mail:send-email($contributorMessage, 'public.uni-hamburg.de', ()) ) then
  console:log('Sent Message to contributor OK')
else
  console:log('message not sent to contributor')
  
  
  
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
                    src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
                <script
                    type="text/javascript"
                    src="https://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
                <script
                    type="text/javascript"
                    src="https://cdn.jsdelivr.net/jquery.slick/1.6.0/slick.min.js"></script>
                <script
                    type="text/javascript"
                    src="$shared/resources/scripts/loadsource.js"></script>
                <script
                    type="text/javascript"
                    src="$shared/resources/scripts/bootstrap-3.0.3.min.js"></script>
                
                <title>Save Confirmation</title>
                <style>
                
                </style>
            </head>
            <body>
<div class="alert alert-success">
    <h2>{$title}</h2>
    <p class="lead">Dear <span id="user">{$cU}</span>, Lemma  <a href="/Dillmann/lemma/{$id}" id="filename">{$filename}</a> has been updated successfully!</p>
    <p id="msg">{$cU} left this message after editing: {$msg} </p>
   {if($notifyEditors = 'yes') then <p id="notifyEditors">A notification email has been sent to the editors.</p> else <p>You have not notified the editors about this change. If you wish to do so, please tick the corresponding box next time.</p>}
   <p class="lead">Thank you!</p>
   
  </div>
  <div class="alert alert-info">
  <div id="Lid"  style="display: none;">{$id}</div>
  <div id="old" style="display: none;">{transform:transform($backupedfile, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</div>
   <div id="new" style="display: none;">{transform:transform($rootitem, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</div>
   <div id="diff"/>
   <script type="application/javascript" src="resources/js/diff.js"/>
   
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
                    src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
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