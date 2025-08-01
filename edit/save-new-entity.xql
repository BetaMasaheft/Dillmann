xquery version "3.0" encoding "UTF-8";
import module namespace app="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en" at "../modules/app.xql";
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "../modules/config.xqm";
import module namespace updatefuseki = 'https://www.betamasaheft.uni-hamburg.de/gez-en/updatefuseki' at "../modules/updateFuseki.xqm";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace sm = "http://exist-db.org/xquery/securitymanager";
import module namespace mail = "http://exist-db.org/xquery/mail";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace validation = "http://exist-db.org/xquery/validation";
import module namespace log="http://www.betamasaheft.eu/Dillmann/log" at "../modules/log.xqm";

declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace s = "http://www.w3.org/2005/xpath-functions";

declare namespace l = "http://log.log";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

declare variable $form := request:get-parameter('form', ());
declare variable $formlang := request:get-parameter('formlang', ());
declare variable $msg := request:get-parameter('msg', ());
declare variable $editorsnotification := request:get-parameter('notifyEditors', ());
let $parametersName := request:get-parameter-names()
let $copyparmeters := for $p in $parametersName
let $pv := request:get-parameter($p, ())
return $p ||'=' ||$pv
let $chainpars := string-join($copyparmeters, '&amp;')


let $eachsense := <senses>{for $parm in $parametersName
return
if(starts-with($parm, 'sense')) then(
let $couple := <couple><sense>{request:get-parameter($parm,())}</sense><source>{request:get-parameter(('source' || substring-after($parm, 'sense')),())}</source></couple>
return
app:upconvertSense($couple)
)
else()}</senses>


let $cU := sm:id()//sm:real/sm:username/string()

let $app-collection := '/db/apps/gez-en'
let $data-collection := '/db/apps/DillmannData'
let $newdata-collection := '/db/apps/DillmannData/new'
let $next-id-file-path := concat($app-collection,'/edit/next-id.xml')

let $nexN := max(collection($data-collection)//t:entry/@n) + 1
let $Newid := doc($next-id-file-path)/data/id[1]/text()
let $newid := $Newid
let $file := concat($newid, '.xml')

return
    if (collection($data-collection)//id($newid)) then
        (
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
                    src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
                <script
                    type="text/javascript"
                    src="https://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
                <script
                    type="text/javascript"
                    src="https://cdn.jsdelivr.net/jquery.slick/1.6.0/slick.min.js"></script>
                <script
                    type="text/javascript"
                    src="resources/scripts/bootstrap-3.0.3.min.js"></script>

                <title>This id already exists!</title>
            </head>
            <body>
                <div
                    id="confirmation">
                    <p>Dear {sm:id()//sm:real/sm:username/string()}, unfortunately <span
                            class="lead">{$newid}</span> already exists!
                        Please, hit the button below and try a different id.</p>
                    <a
                        href="/Dillmann/newentry.html"
                        class="btn btn-success">back to list</a>
                </div>

            </body>
        </html>
        )
    else
        let $editor := switch ($cU)
           case 'Andreas'
                return
                    'AE'
             case 'Maria'
                return
                    'MB'
           case 'Pietro'
                return
                    'PL'
           case 'Magda'
                return
                    'MK'
           case 'Jeremy'
                return
                    'JB'
           case 'Joshua'
                return
                    'JF'
            case 'Susanne'
                return
                    'SH'
            case 'Wolfgang'
                return
                    'WD'
            case 'Alessandro'
                return
                    'AB'
            case 'Vitagrazia'
                return
                    'VP'
            case 'Eugenia'
                return
                    'ES'
            default return
                'unknown'
                (: get the form data that has been "POSTed" to this XQuery :)
    let $item :=
    document {
        processing-instruction xml-model {
            'href="https://raw.githubusercontent.com/BetaMasaheft/Dillmann/master/schema/Dillmann.rng"
schematypens="http://relaxng.org/ns/structure/1.0"'
        },
        processing-instruction xml-model {
            'href="https://raw.githubusercontent.com/BetaMasaheft/Dillmann/master/schema/Dillmann.rng"
type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'
        },
        <TEI
            xmlns="http://www.tei-c.org/ns/1.0"
            xml:lang="en">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title
                            xml:lang="{$formlang}">{$form}</title>
                       <editor>Alessandro Bausi</editor>
                </titleStmt>
                <publicationStmt>
                       <authority>Hiob-Ludolf-Zentrum für Äthiopistik</authority>
                <publisher>Hiob-Ludolf-Zentrum für Äthiopistik</publisher>
                <pubPlace>Hamburg</pubPlace>
                <availability>
                    <licence target="https://creativecommons.org/licenses/by-sa-nc/4.0/">
                                        This file is licensed under the Creative Commons
                                        Attribution-ShareAlike Non Commercial 4.0. </licence>
                </availability>
            </publicationStmt>
            <sourceDesc>
                <p>The origin of the lexicon is in a thoroughly elaborated txt version of <ref xml:id="dillmann"
                  target="https://archive.org/details/lexiconlinguaeae00dilluoft">Dillmann,
                  Christian Friedrich August. <emph>Lexicon linguae aethiopicae, cum indice latino.
                     Adiectum est vocabularium tigre dialecti septentrionalis compilatum</emph> a W.
                  Munziger. Lipsiae: Th.O. Weigel, 1865.</ref>
            </p>
            <p>Additional records were created by the project <ref xml:id="traces" target="https://www.traces.uni-hamburg.de/">
                  TraCES (ERC Advanced Grant, Grant Agreement 338756) and follow-up projects at HLCEES</ref></p>
             <p>Sources include also <ref xml:id="grebaut"
                  target="https://archive.org/details/supplmentaulexic0000grba">Sylvain Grébaut, Supplément au lexicon linguae aethiopicae de August Dillmann: (1865) et édition du lexique de Juste d'Urbin (1850 - 1855), Paris: Imprimerie Nationale, 1952</ref> and <ref xml:id="leslau">Wolf Leslau, Comparative Dictionary of Geʻez (Classical Ethiopic): Geʻez-English, English-Geʻez, with an Index of the Semitic Roots, Wiesbaden: Harrassowitz, 1987</ref></p>
            </sourceDesc>

                </fileDesc>

                  <encodingDesc>
                        <p>A digital edition of the Lexicon in TEI.</p>
                        <listPrefixDef>
                 <prefixDef ident="bm"
                    matchPattern="([a-zA-Z0-9]+)"
                    replacementPattern="https://www.zotero.org/groups/358366/ethiostudies/items/tag/bm:$1">
                </prefixDef>
                </listPrefixDef>
                    </encodingDesc>
                <profileDesc>

             <langUsage>
                 <language ident="en">English</language>
                 <language ident="fr">French</language>
                <language ident="de">German</language>
                <language ident="la">Latin</language>
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
                        who="{$editor}"
                        when="{format-date(current-date(), "[Y0001]-[M01]-[D01]")}">{$msg}</change>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <div>
                <entry xml:id="{$newid}" n="{$nexN}">
                    <form>
                        <foreign xml:lang="{$formlang}">{$form}</foreign>
                    </form>
                    {for $s in $eachsense//t:sense return $s}

                </entry>
                </div>
               </body>
            </text>
        </TEI>
        }


(:validate:)
let $schema := doc('/db/apps/gez-en/schema/Dillmann.rng')
            let $validation := validation:jing($item, $schema)
            return
            if($validation = true()) then (
(:    create file:)

let $store := xmldb:store($newdata-collection, $file, $item)
let $record := $config:collection-root//id($newid)

(:the senses without id should have been updated and the id can be injected into them, the main sense is instead already in the upconversion step:)
let $addxmlids := for $sensewithoutid in $record//t:sense[@n]
                            let $mainSense := $sensewithoutid/ancestor::t:sense[@source]
                            let $parentSense := for $pS in $sensewithoutid/ancestor::t:sense[@n] 
                                                            let $position := count($pS/ancestor::t:sense) 
                                                            order by $position 
                                                            return string($pS/@n)
                            let $newId := substring($mainSense/@xml:id,1,1) || string-join($parentSense) || string($sensewithoutid/@n)
                            return 
                                      update insert attribute xml:id {$newId} into $sensewithoutid
                                      
let $updateFuseki := try {updatefuseki:entry($record, 'INSERT') } catch * {util:log("warn", 'failed to update fuseki')}
(: update the next-id.xml file :)
let $remove-used-id := update delete doc($next-id-file-path)/data/id[1]

(:    permissions:)
   let $assigntoGroup := sm:chgrp(xs:anyURI($newdata-collection||'/'||$file), 'lexicon')
   let $setpermissions := sm:chmod(xs:anyURI($newdata-collection||'/'||$file), 'rwxrwxr-x')
   (:
    (:nofity editor and contributor:)
     let $sendmails :=(
     let $contributorMessage := <mail>
    <from>aethiopistik@uni-hamburg.de</from>
    <to>magdalena.krzyzanowska-2@uni-hamburg.de</to>
    <!--<to>{sm:get-account-metadata($cU, xs:anyURI('http://axschema.org/contact/email'))}</to>-->
    <cc></cc>
    <bcc></bcc>
    <subject>Thank you from Lexicon Linguae Aethiopicae for your contribution!</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>You have just created a new entry for {$form} </title>
               </head>
               <body>
                  <h1>Thank you for creating a new entry for {$form}!</h1>
                  <p>{$form} has been assigned the unique id {$newid}</p>
                  <p>This is how the txt version looks like now:</p>
                  <p>{transform:transform($item, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</p>
                  <p><a href="https://betamasaheft.eu/Dillmann/lemma/{$newid}"
                  target="_blank">See {$form} online!</a> There you can also update the file again.</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
if ( mail:send-email($contributorMessage, 'public.uni-hamburg.de', ()) ) then
  util:log("info", 'Sent Message to editor OK')
else
  util:log("info", 'message not sent to editor')

 ,

  let $EditorialBoardMessage := <mail>
    <from>eugenia.sokolinski@uni-hamburg.de</from>
    {if($editorsnotification = 'yes') then
    (<to>aethiopistik@uni-hamburg.de</to>,
    <to>magdalena.krzyzanowska-2@uni-hamburg.de</to>) else ()}
    <subject>Lexicon Linguae Aethiopicae says: {$form} has been created!</subject>
    <message>
      <xhtml>
           <html>
               <head>
                 <title>{$cU} has just created {$form}</title>
               </head>
               <body>
                  <h1>{$cU} just created a new entry for {$form}!</h1>
                  <p>{$cU} left this message on saving the entry: <i>{$msg}</i> </p>
                  <p>{$form} has been assigned the unique id {$newid}</p>
                  <p>This is how the txt version looks like now:</p>
                  <p>{transform:transform($item, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</p>
                  <p><a href="https://betamasaheft.eu/Dillmann/lemma/{$newid}"
                  target="_blank">See {$form} online!</a> There you can also update the file again.</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
if ( mail:send-email($EditorialBoardMessage, 'public.uni-hamburg.de', ()) ) then
  util:log("info", 'Sent Message to editor OK')
else
  util:log("info", 'message not sent to editor')
):)
(:
let $log := log:add-log-message('/Dillmann/lemma/'||$newid,sm:id()//sm:real/sm:username/string(), 'created')
:)
    (:confirmation page with instructions for editors:)
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
                    src="resources/scripts/bootstrap-3.0.3.min.js"></script>

                <title>Save Confirmation</title>
            </head>
            <body>
                <div
                    id="confirmation" class="col-md-4 col-md-offset-4 alert alert-success"><h1
                        class="lead">Thank you very much {sm:id()//sm:real/sm:username/string()}!</h1>
                    <p> Your entry for 
                        <a href="/Dillmann/lemma/{substring-before($file, '.xml')}" target="_blank"><span
                            class="lead">{$form}</span></a> has been saved!</p>
                   {if($editorsnotification = 'yes') then (<p>A notification email has been sent to you for your records and to the editors.</p>) else <p>You have not notified the editors about this change. If you wish to do so, please tick the corresponding box next time.</p>}
                    <a
                        href="/Dillmann/newentry.html">Create another entry!</a>
                        <a role="button" href="/Dillmann/" class="btn btn-info">Home</a>
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
                    src="resources/scripts/bootstrap-3.0.3.min.js"></script>


                <title>Save Confirmation</title>

            </head>
            <body>
                <div class="col-md-12 alert alert-warning"><div class="col-md-6"><p class="lead">Sorry, the document you are trying to save is not valid. There is probably an error in the content somewhere. Below you can see the report from the schema. Beside the XML, check it out or send the link or a screenshoot to somebody for help.</p>
                <pre>{validation:jing-report($item, $schema)}</pre></div>
                <div class="col-md-6"><div id="editorContainer"><div id="ACEeditor">{$item//t:entry}</div></div></div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.6/ace.js" type="text/javascript" charset="utf-8"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.6/ext-language_tools.js" type="text/javascript" charset="utf-8"></script>
            </div>
<script src="resources/js/ACEsettings.js"/>
            </body>
        </html>

        )
