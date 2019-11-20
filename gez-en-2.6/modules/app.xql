xquery version "3.0";

module namespace app="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mail="http://exist-db.org/xquery/mail";
declare namespace functx = "http://www.functx.com";
declare namespace expath="http://expath.org/ns/pkg";
declare namespace l = "http://log.log";

import module namespace kwic = "http://exist-db.org/xquery/kwic"    at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace validation = "http://exist-db.org/xquery/validation";
import module namespace log="http://www.betamasaheft.eu/log" at "log.xqm";

declare variable $app:SESSION := "gez-en:all";
declare variable $app:searchphrase as xs:string := request:get-parameter('q',());
declare variable $app:abbreviaturen := doc('/db/apps/gez-en/abbreviaturen.xml');

declare function functx:contains-any-of( $arg as xs:string? ,$searchStrings as xs:string* )  as xs:boolean {

   some $searchString in $searchStrings
   satisfies contains($arg,$searchString)
 } ;
(:modified by applying functx:escape-for-regex() :)
declare function functx:number-of-matches ( $arg as xs:string? ,    $pattern as xs:string )  as xs:integer {

   count(tokenize(functx:escape-for-regex(functx:escape-for-regex($arg)),functx:escape-for-regex($pattern))) - 1
 } ;
declare function functx:escape-for-regex( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;


  declare function app:personslist($node as element(), $model as map(*)){

if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
 let $BMpersons := collection('/db/apps/BetMas/data/persons/')//tei:person[tei:persName[@xml:lang='gez'][not(@type='normalized')]]
 let $hits := for $BMperson in subsequence($BMpersons,1,50) return $BMperson
 return
 map {'hits' := $hits}
 )
 else ('sorry, this page is only for editors')
 };


declare
%templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 50)
    function app:persRes (
    $node as node(),
    $model as map(*), $start as xs:integer, $per-page as xs:integer) {

    for $pers at $p in subsequence($model("hits"), $start, $per-page)
        let $id := root($pers)/tei:TEI/@xml:id
            let $names := for $name in $pers/tei:persName[@xml:lang='gez'][not(@type='normalized')] return $name
            let $mainName := normalize-space(string-join($names[@xml:id='n1']/text(), ' '))
            let $eval-string := concat("$config:collection-root//tei:form/tei:foreign[ft:query(.,'", $mainName, "')]")
                 let $hits := for $hit in util:eval($eval-string) order by ft:score($hit) descending return $hit
          return
            <div class="w3-row-padding reference ">
               <div class="w3-quarter"><div class="w3-half"><a target="_blank" href="/{data($id)}">{string($id)}</a></div>
<div class="w3-half">{string-join($names, ', ')}</div></div>
               <div class="w3-threequarter">
               {
               if(count($hits) gt 1) then
               (
               <div class="w3-container w3-margin-64">
               <div class="w3-quarter">We have found this entry in Dillmann: { for $hit in $hits let $hitID := string(root($hit)//tei:entry/@xml:id) return (<a target="_blank" href="/Dillmann/lemma/{$hitID}">{$hit}</a>, ', ')}</div>
               <div class="w3-threequarter w3-panel w3-red">If you do not think any of the hits matches this entry you can create a new personal name entry.
               <form class="form-inline" id="createnew" action="/Dillmann/edit/save-new-entity.xql" method="post">
               <div class="form-group"><input class="form-control" id="form" name="form" value="{$mainName}" hidden="hidden"></input>
               </div>
               <div class="form-group"><input class="form-control" id="sourceen" name="sourceen" value="traces" hidden="hidden"></input>
               </div>
               <div class="form-group"><textarea class="form-control" id="senseen" name="senseen">{'<Sen< \*gez*'||$mainName||'\* [[ +n.pr.+ ]] {ND} >S>'}</textarea>
              </div>
              <div class="form-group"><textarea class="form-control" id="msg" name="msg" required="required">{'added persName from list of persons with a normalized Gǝʿǝz name in Beta Maṣāḥǝft'}</textarea>
               </div><button type="submit" class="btn btn-primary">create new entry</button>
               </form>
               </div>
               </div>) else
               <div class="w3-container w3-margin">
               <div class="w3-quarter">We have not found this entry in Dillmann.</div>
               <div class="w3-threequarter w3-panel w3-lightyellow w3-card-2">You can create here a new personal name entry for this. Check, edit and submit.
               <form class="form-inline" id="createnew" action="/Dillmann/edit/save-new-entity.xql" method="post">
               <div class="form-group"><input class="form-control" id="form" name="form" value="{$mainName}" hidden="hidden"></input>
               </div>
               <div class="form-group"><input class="form-control" id="sourceen" name="sourceen" value="traces" hidden="hidden"></input>
               </div>
               <div class="form-group"><textarea class="form-control" id="senseen" name="senseen">{'<Sen< \*gez*'||$mainName||'\* [[ +n.pr.+ ]] {ND} >S>'}</textarea>
              </div>
              <div class="form-group"><textarea class="form-control" id="msg" name="msg" required="required">{'added persName from list of persons with a normalized Gǝʿǝz name in Beta Maṣāḥǝft'}</textarea>
               </div><button type="submit" class="btn btn-primary">create new entry</button>
               </form>
               </div>
               </div>
               }
               </div>

            </div>





    };

 declare function app:userPage($node as element(), $model as map(*)){

let $username := request:get-parameter("username", "")
return
if ($username = 'guest') then (
<div
                id="content"
                class="container-fluid w3-container w3-margin">
                <p>Did you just arrive here by mistake or do you want to know what people look at on ths webiste? You can ask Pietro, he will provide you the data from google analytics, which is much nicer.</p>
                </div>
)
else if(($username = xmldb:get-current-user())or xmldb:is-admin-user(xmldb:get-current-user())) then

<div
                id="content"
                class="container-fluid w3-container w3-margin">
                <h2>{if($username != xmldb:get-current-user()) then 'Dear ' || xmldb:get-current-user() || ' you see this because you are admin. --->' else ()}
                Dear {$username}, thank you very much for all your nice work for the project!</h2>
                <div
                    class="w3-container w3-margin">
                    <div class="w3-container w3-margin alert alert-success">
                    <h2>All about you... </h2>
                    <p><b>User name: </b> {$username}</p>
                    <p><b>Member of: </b>{let $groups := for $g in sm:get-user-groups($username) return $g return string-join($groups, ', ')}</p>
                    {for $x in sm:get-account-metadata-keys($username) return <p><b>{switch($x) case 'http://exist-db.org/security/description' return 'Role: ' case 'http://axschema.org/namePerson' return 'Full name: ' case 'http://axschema.org/contact/email' return 'E-mail: ' default return ()}</b>  {sm:get-account-metadata($username,$x)}</p>}
                    </div>
                    <div class="w3-container w3-margin w3-panel w3-lightyellow w3-card-2">
                    <a href="/Dillmann/latestchanges.html">See a list of all latest changes</a>
                    </div>
                    <div
                        class="w3-half w3-panel w3-lightygreen w3-card-2">
                        {let $userinitials := app:editorNames($username)
                                    let $changes := $config:collection-root//tei:change[@who = $userinitials][@when gt '2017-04-19']
                                     let $changed := for $c in $changes
                                                                order by $c/@when descending
                                                                 return $c
                                    return
                                        (
                                        <h3>Your made {count($changes)} changes in these files after the last conversion of the data from the original txt (19.4.2017).</h3>,
                        <div  class=" w3-container w3-margin userpanel"><table
                                class="w3-table w3-hoverable"><thead><tr><th>item</th><th>date and time</th><th>change</th></tr></thead><tbody>{

                                    for $itemchanged in $changes
                                     let $root := root($itemchanged)
                                    let $id := $root//tei:entry/@xml:id
                                    group by $ID := $id
                                    let $form := root($ID)//tei:entry/tei:form/tei:foreign/text()
                                    let $maxchange := max(root($ID)//tei:change[@who = $userinitials]/xs:date(@when))
                                    let $maxdate := xs:date($maxchange)
                                     order by $maxchange descending
                                    return
                                        (<tr style="font-weight:bold;  border-top: 4px solid #5bc0de">
                                        <td><a
                                                href="/Dillmann/lemma/{string($ID)}">{$form}</a>{if(root($ID)//tei:nd) then (' ', <label class="w3-tag w3-lightgreen">NEW</label>) else ()}</td><td></td><td></td></tr>,
                                                for $changeToItem in $itemchanged
                                                order by $changeToItem/@when descending
                                                return <tr><td></td>
                                        <td>{format-date($changeToItem/@when, "[D01].[M01].[Y1]")}</td>
                                                <td>{$changeToItem/text()}</td>
                                                </tr>)
                                }</tbody></table></div>
                                )
                                }
                    </div>
                    <div
                        class="w3-half"><h3>The last 50 pages you visited</h3>
                        <div  class=" w3-container w3-margin userpanel"><table
                                class="w3-table w3-hoverable"><thead><tr><th>type</th><th>date and time</th><th>info</th></tr></thead><tbody>{
                                       let $selection :=  for $c in collection('/db/apps/gez-en/log/')//l:logentry[l:user[. = $username]][not(l:type[.='query'])][not(contains(l:type, 'XPath'))]
                                                                  order by $c/@timestamp descending
                                                                  return $c
                                       for $loggedentity in subsequence($selection, 1, 50)
                                        return
                                            <tr><td>{$loggedentity/l:type/text()}</td><td>{
                                            format-dateTime($loggedentity/@timestamp,
                 "[D01].[M01].[Y1] [H01]:[m01]:[s01]")
                                            }</td><td><a
                                            href="{$loggedentity/l:url/text()}">{$loggedentity/l:url/text()}</a></td></tr>
                                    }</tbody></table>
                        </div>
                    </div>
                    </div>
                    </div>
                    else (
                    <div
                id="content"
                class="container-fluid w3-container w3-margin">
                <p>Thank you very much for you interest in user data! You are either not logged in or you are trying to look somebody else data.
                If the first case is true, then please log in. If the second is true, I am quite sure you know how to call them or where they sit, so go and have a chat directly with them. If neither of this is true, then something is wrong, please open an issue.</p>
                </div>
                    )
 };

 declare function app:latestchanges($node as node(), $model as map(*)){
 let $selection :=  for $c in collection('/db/apps/gez-en/log/')//l:logentry[l:type[.='updated'] or l:type[.='backup'] or l:type[. = 'created'] or l:type[contains(., 'delete')]][not(l:user = 'Pietro')]
                                                                  order by $c/@timestamp descending
                                                                  return $c
  return
  (
  <input class="form-control"  type="text" id="searchStringType" onkeyup="searchInTable()" placeholder="Search in the type"/>,
<table class="w3-table w3-hoverable" id="latestchangestable">
<thead>
<tr>
<th>type of event</th>
<th>date</th>
<th>user</th>
<th>lemma</th>
<th>description of change</th>
</tr>
</thead>
<tbody>
                                     {
                                     for $loggedentity in subsequence($selection, 1, 200)
                                     let $type := $loggedentity/l:type/text()
                                     let $user := $loggedentity/l:user/text()
                                     let $logurl := $loggedentity/l:url
                                     let $urlid :=
                                           if(matches($logurl, 'L[\w\d]{32}'))
                                           then (
                                                    switch($type)
                                                    case 'delete confirmation requested' return substring-after($logurl, '/Dillmann/lemma/')
                                                    case 'updated' return '/Dillmann/lemma/' ||$logurl/text()
                                                    default return $logurl/text()
                                                    )
                                           else $logurl/text()

                                     let $what := switch($type)
                                    case 'deleted' return $logurl/text()
                                    case 'backup' return $logurl/text()
                                    case 'delete confirmation requested' return substring-after($logurl, '/Dillmann/lemma/')
                                    default return
                                             <a target="_blank" href="{$urlid}">{if(contains($urlid, 'lemma'))
                                                                then (
                                                                 let $id := substring-after($urlid, 'lemma/')
                                                                 let $doc := $config:collection-root//id($id)
                                                                 let $name := $doc//tei:form/tei:foreign[1]/text()
                                                                   return $name
                                                                 )
                                                                 else $urlid}</a>

                                     let $description := if($type='updated' or $type='created') then (
                                     <ul>{
                                        let $id := $loggedentity/l:url/text()
                                        let $doc := root( $config:collection-root//id($id))
                                         let $t := format-dateTime($loggedentity/@timestamp, '[Y0001]-[M01]-[D01]')
                                        for $change in $doc//tei:change[@when = $t]
                                            return <li>{$change/text()}</li>
                                     }</ul>
                                     ) else ()

                                        return
                                        <tr>
                                        <td>{$type}</td>
                                        <td>{format-dateTime($loggedentity/@timestamp, '[D01].[M01].[Y0001] at [H01]:[m01]:[s01]')}</td>
                                        <td>{$user}</td>
                                        <td>{$what}</td>
                                        <td>{$description}</td>
                                        </tr>}</tbody>
</table>
 )};

 (:~ logging function to be called from templating pages:)
declare function app:logging ($node as node(), $model as map(*)){

let $url :=  replace(request:get-uri(), '/exist/apps/gez-en', '/Dillmann')
 let $parameterslist := request:get-parameter-names()
   let $paramstobelogged := for $p in $parameterslist for $value in request:get-parameter($p, ()) return ($p || '=' || $value)
   let $logparams := if(count($paramstobelogged) >= 1) then '?' || string-join($paramstobelogged, '&amp;') else ()
   let $logurl := $url || $logparams
   return
   log:add-log-message($logurl, xmldb:get-current-user(), 'page')

};

(:the forms in the advanced search. this are called by a ajax call requesting as.html as a part of the html output.
Jquery cares also about the loading it once only and then simply hiding or showing it. :)
 declare function app:forms($node as element(), $model as map(*)){
 let $data-collection := '/db/apps/DillmannData'
    let $collection :=  $config:collection-root

return (
<div class="w3-container w3-margin">
<div class="form-group erweit  w3-quarter">
                        <small class="form-text text-muted">Search for entries which (don't) contain corresponding words in </small>
                        <div  id="languages">
                        <label class="switch">
                            <input type="checkbox" name="notlang"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            <input class="w3-check" type="checkbox" name="languages" value="ar"/>Arabic<br/>
                            <input class="w3-check" type="checkbox" name="languages" value="grc"/>Greek<br/>
                            <input class="w3-check" type="checkbox" name="languages" value="cop"/>Coptic<br/>
                            <input class="w3-check" type="checkbox" name="languages" value="la"/>Latin<br/>
                            <input class="w3-check" type="checkbox" name="languages" value="syr"/>Syriac<br/>
                            <input class="w3-check" type="checkbox" name="languages" value="he"/>Hebrew<br/>
                        </div>
                </div>
                <div class="form-group erweit  w3-quarter">
                        <small class="form-text text-muted">Search for entries which (don't) contain this case </small>
                        <div id="case">
                            <label class="switch">
                            <input type="checkbox" name="notcase"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>

                            <input class="w3-check" type="checkbox" name="case" value="accusativus"/>accusativus<br/>
                            <input class="w3-check" type="checkbox" name="case" value="dativus"/>dativus<br/>
                        </div>
                </div>
                <div class="form-group erweit w3-quarter">
                        <small class="form-text text-muted">Search for entries which (don't) contain this gender </small>
                        <div id="gender">
                            <label class="switch">
                            <input type="checkbox" name="notgen"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            <input class="w3-check" type="checkbox" name="case" value="f"/>femininus<br/>
                            <input class="w3-check" type="checkbox" name="case" value="m"/>masculinus<br/>
                        </div>
                </div>
                <div class="form-group erweit w3-quarter">
                        <small class="form-text text-muted">Search for entries which match this verb subcategory </small>
                        <div id="gender">
                            <label class="switch">
                            <input type="checkbox" name="notsubc"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            <input class="w3-check" type="checkbox" name="subc" value="I,1"/>I,1<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="I,2"/>I,2<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="I,3"/>I,3<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="II,1"/>II,1<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="II,2"/>II,2<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="II,3"/>II,3<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="III,1"/>III,1<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="III,2"/>III,2<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="III,3"/>III,3<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="IV,1"/>IV,1<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="IV,2"/>IV,2<br/>
                            <input class="w3-check" type="checkbox" name="subc" value="IV,3"/>IV,3<br/>
                        </div>
                </div>
</div>,
                <div class="w3-container w3-margin">
                <div class="form-group erweit w3-half">
<small class="form-text text-muted">Search for entries which (don't) contain this PoS </small>
                        <div id="PoS">
                            <label class="switch">
                            <input type="checkbox" name="notpos"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            {for $x in distinct-values($collection//tei:pos/@expand) return (<input  class="w3-check" type="checkbox" name="pos" value="{$x}"/>, $x, <br/>)}

                        </div>
                </div>

<div class="form-group erweit  w3-half">
                        <small class="form-text text-muted">Search for entries which (do not) contain this label </small>
                        <div id="lbl">
                            <label class="switch">
                            <input type="checkbox" name="notlbl"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                           { for $x in distinct-values($collection//tei:lbl/@expand) return (<input  class="w3-check" type="checkbox" name="lbl" value="{$x}"/>, $x, <br/>)}

                        </div>
                </div>
</div>


               )
 };

(: returns a map with all the translation terms in the dictionary and each language represented:)
 declare
 %templates:wrap
    %templates:default("lang", 'la')
    %templates:default("mode", 'cit')
    function app:quotes($node as element(), $model as map(*), $letter as xs:string?, $lang as xs:string?, $mode as xs:string){
(:     if a parameter letter is given, then construct xpath to select only the elements whose content starts with that letter.
The letters are available as buttons on the side bar and when clicked will reload the page with that parameter. :)
    let $starts-with := if($letter) then ('[starts-with(.,"' || $letter || '")]') else ()
    let $data-collection := '/db/apps/DillmannData'
    let $collection :=  $config:collection-root
(:    selects the cit elements, which contain translations and output distinct values of the language for the side menu:)
    let $langs := if($mode='foreign') then (distinct-values($collection//tei:foreign/@xml:lang)) else distinct-values($collection//tei:cit/@xml:lang)
(:    selects among cit elements with the selected language, by default latin as it is majoritary:)
    let $translations := if($mode='foreign') then ($collection//tei:foreign[@xml:lang = $lang]) else $collection//tei:cit[@type='translation'][@xml:lang = $lang]
(:    build the query with the letter parameter:)
    let $query:= if($mode='foreign') then ('$translations' || $starts-with) else '$translations/tei:quote' || $starts-with

    let $trans := for $word at $p in util:eval($query)
            let $trimmedword := replace(replace($word,'\s+$',''),'^\s+','')
            let $root := root($word)//tei:entry/@xml:id
            group by $t := $trimmedword
            order by $t

                return
                     map {
                         "hit" := $t,
                         "roots" := (for $r in $root
                            return string($r))
                     }
    return
        map {'hits' := $trans, 'langs' := $langs}

 };

(: takes map result from app:quotes and prints a navbar with buttons to filter results and the selected results:)
 declare
 %templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 50)
    function app:reverse($node as element(), $model as map(*), $start as xs:integer, $per-page as xs:integer){
 let $data := $model('hits')
 let $langs := $model('langs')
 let $m := request:get-parameter('mode', ())
 let $l := request:get-parameter('lang', ())
 let $mpar := if($m) then ('&amp;mode=' || $m) else ()
 let $lpar := if($l) then ('&amp;lang=' || $l) else ()
 return

     <div class="w3-container w3-margin">
     <div class="w3-quarter w3-animate-left">
     <div class="w3-bar-block w3-margin">
     <a class="w3-bar-item w3-button w3-green"   href="?start=1&amp;mode=cit">list translations (default)</a>
     <a class="w3-bar-item w3-button w3-green"  href="?start=1&amp;mode=foreign">non latin terms</a>
     </div>
     <div class="w3-bar-block w3-margin">
     {for $lang in distinct-values($langs)
        return
        if ($lang = 'gez') then () else
                <a class="w3-bar-item w3-button w3-pale-green" href="?start=1&amp;lang={$lang}{$mpar}">{$lang}</a>}
      </div>
     <div class="w3-bar-block w3-margin">{for $hit in $data
         let $first := substring($hit('hit'), 1, 1)
            group by $f := $first
            return
               <a class="w3-bar-item w3-button w3-blue" href="?start=1&amp;letter={$f}{$mpar}{$lpar}">{$f} <span class="w3-badge w3-right w3-margin-right">{count($hit)}</span></a>}
               <a class="w3-bar-item w3-button w3-green" href="?start=1{$mpar}{$lpar}">back to full list</a>
      </div>

      </div>
          <div class="w3-threequarter">  { if (count($data) lt 1) then (<div class="w3-panel w3-card-2">Please select a value on the side bar.</div>) else
          <div class="w3-margin w3-container">{
 for $hit in subsequence($data, $start, $per-page)
 return
 <div class="row">
     <div class="w3-third">{$hit('hit')}</div>
     <div  class="w3-twothird">
     <div class="w3-bar-block">
     {for $r in $hit('roots')

     let $entry :=  $config:collection-root//id($r)
     let $term-name := let $terms := $entry//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms

         return
             <a class="w3-bar-item" target="blank" href="/Dillmann/lemma/{$r}">{$term-name}</a>
     }
        </div>
     </div>
 </div>}
 </div>
 }</div>
 </div>
 };


(: as per requirement it is possible to transform the entire data in a huge txt file. this is stored in the app and then made available for download. the request takes some time...:)
 declare function app:download($node as element(), $model as map(*)){
   let $data-collection := '/db/apps/DillmannData/'
   let $txtarchive := '/db/apps/gez-en/txt/'
   (: store the filename :)
   let $filename := concat('Dillmann_Lexicon_', format-dateTime(current-dateTime(), "[Y,4][M,2][D,2][H01][m01][s01]"), '.txt')
   let $filecontent := for $d in  $config:collection-root
               order by $d//tei:entry/@n
                return
                                      transform:transform($d, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())
 let $Text := string-join($filecontent, ' &#13;')
    (: create the new file with a still-empty id element :)
    let $store := xmldb:store($txtarchive, $filename, $Text)
return
 <a
    id="downloaded"
    href="{$config:appUrl}:8080/exist/apps/gez-en/txt/{$filename}"
    download="{$filename}"
    class="btn btn-primary"><i
        class="fa fa-download"
        aria-hidden="true"></i> Download all Dillmann Lexicon as txt file</a>
 };

(: this allows a user to create an account. it is actually usable but no link points here:)
 declare function app:createaccount(
 $node as element(),
 $model as map(*)){
 <div class="container">
 <form class="form" action="/Dillmann/accounts/createaccount.xql">
 <label for="n"><b>Full Name</b></label>
    <input id="n"  class="form-control" type="text" placeholder="Enter your name" name="name" required="required"/>

<label for="u"><b>User Name</b></label>
    <input  id="u" class="form-control" type="text" placeholder="Choose a User name" name="usr" required="required"/>

<label for="e"><b>Email</b></label>
    <input id="e"   class="form-control" type="email" placeholder="enter your email" name="email" required="required"/>


    <label for="p"><b>Password</b></label>
    <input id="p"  class="form-control" type="password" placeholder="Enter Password" name="psw" required="required"/>

    <label for="p2"><b>Repeat Password</b></label>
    <input id="p2" class="form-control" type="password" placeholder="Repeat Password" name="psw-repeat" required="required"/>

      <a class="btn btn-secondary"  href="/Dillmann/">Cancel</a>
      <button type="submit" class="btn btn-success">Sign Up</button>
 </form>
 </div>
 };

(: this function decides if to print the login form or logout form. only logged in users will be recognized and if in the correct group will see the buttons to edit and create new entries:)
 declare function app:login(
 $node as element(),
 $model as map(*)){
 if(sm:id()//sm:username/text() = 'guest') then

 <div class="w3-bar-item w3-hide-small w3-dropdown-hover "  style="margin:0;padding:0" id="logging">
      <button class="w3-button w3-red w3-bar-item">Login <i class="fa fa-caret-down"></i></button>
      <div class="w3-dropdown-content w3-bar-block w3-card-4">

	<form method="post" class="w3-container" role="form"
	accept-charset="UTF-8" id="login-nav">
                    <label for="user">User:</label>
                            <input type="text" name="user" required="required" class="w3-input"/>

                        <label for="password">Password:</label>
                            <input type="password" name="password" class="w3-input"/>

                            <button class="w3-button w3-small w3-red" type="submit">Login</button>

                </form>
                </div>
                </div>
                else
              <form method="post" action="" class="w3-bar-item w3-hide-smal" style="margin:0;padding:0" role="form" accept-charset="UTF-8" id="logout-nav">

              <button  class=" w3-button w3-red w3-bar-item" type="submit">Logout</button>

              <input value="true" name="logout"  type="hidden"/>

              </form>
 (:
 if(xmldb:get-current-user() = 'guest') then
 <li class="dropdown">
          <a href="#"
          class="dropdown-toggle"
          data-toggle="dropdown"><b>Login</b>
          <span class="caret"></span></a>
			<ul id="login-dp" class="dropdown-menu">
				<li>
		 <div class="row">
			<div class="w3-container w3-margin">
			<form method="post" class="form" role="form" accept-charset="UTF-8" id="login-nav">
                    <div class="form-group">
                        <label class="control-label col-md-1" for="user">User:</label>
                            <input type="text" name="user" required="required" class="form-control"/>

                    </div>
                    <div class="form-group">
                        <label class="control-label col-md-1" for="password">Password:</label>
                            <input type="password" name="password" class="form-control"/>

                    </div>

                    <div class="form-group">
                        <div class="col-md-offset-1 col-sm-12">
                            <button class="btn btn-primary" type="submit">Login</button>

                        </div>
                    </div>
                </form>
							</div>
							 </div>
				</li>

			</ul>
        </li>
 (\: goes with login button, had to put it here to comment it out...
	<a class="btn btn-primary"  href="/Dillmann/createaccount.html">Create a new account</a>
		:\)
                else
              <li  class="dropdown">
              <form method="post" action="" class="navbar-form" role="form" accept-charset="UTF-8" id="logout-nav">
               <input value="true" name="logout" class="form-control" type="hidden"/>

              <button  class="btn btn-primary btn-xs" type="submit">Logout</button>
              </form>
              </li>:)
};

(:on login, print the name of the logged user:)
declare function app:greetings($node as element(), $model as map(*)){
<a target="_blank" href="/Dillmann/user/{xmldb:get-current-user()}">Hi {xmldb:get-current-user()}!</a>
    };

(:the button to the pdf of a file. the request ending with .pdf triggers in the controller a xslt transformation    :)
 declare function app:pdf-link($id) {

        <a class=" w3-bar-item w3-button w3-pale-blue" xmlns="http://www.w3.org/1999/xhtml" href="{$id}.pdf">{'pdf'}</a>
};

(:the button which allows to download the source xml file:)
 declare function app:getXML($id){
 <a
    href="https://betamasaheft.eu/Dillmann/lemma/{$id}.xml"
    download="{$id}.xml"
    class=" w3-bar-item w3-button w3-blue"><i
        class="fa fa-download"
        aria-hidden="true"></i>TEI/XML</a>
 };


(:    the button linking the the new entry form, an html page with a form posting data to a xql which will store a file and notify the editors:)
   declare function app:newentry($node as element(), $model as map(*)) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a class="w3-button w3-green" href="/Dillmann/newentry.html">
                   New Entry
                </a>)
else ()
};

(:the link to the download page, only available for lexicon group:)
   declare function app:downloadbutton($node as element(), $model as map(*)) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a class="w3-bar-item w3-button  w3-hide-small  w3-hide-medium" href="/Dillmann/downloads.html">Downloads</a>
)
else ()
};

(:the link to Beta Masaheft, only available for logged users:)
   declare function app:bmbutton($node as element(), $model as map(*)) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a href="https://betamasaheft.eu/" class="w3-bar-item w3-button  w3-hide-small" target="_blank">Beta maṣāḥǝft</a>

)
else ()
};

(:the link to Beta Masaheft, only available for logged users:)
   declare function app:tutorial($node as element(), $model as map(*)) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a href="https://betamasaheft.eu/Dillmann/tutorialextended.html" target="_blank" class="w3-bar-item w3-button  w3-hide-small">Tutorial</a>

)
else (
<a href="https://betamasaheft.eu/Dillmann/tutorial.html" class="w3-bar-item w3-button  w3-hide-small" target="_blank">Tutorial</a>)
};

(:form to navigate Dillmann using the column numbers :)
 declare function app:gotocolumn($node as element(), $model as map(*)) {
  <form action="" class="w3-container" id="GtC">
 
 <div class="w3-bar">
  
  <input type="number" class="w3-input w3-border w3-bar-item" id="columnnumber" aria-describedby="basic-addon3" name="GtC"/>
 <button class="w3-bar-item w3-button w3-gray" type="submit">Go!</button>
  
</div><label id="basic-addon3">column number</label>
</form>
};

(:the button to delete an entry, only available for lexicon group:)

  declare function app:deleteEntry($id) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a class="w3-button w3-red w3-bar-item delete" href="/Dillmann/edit/delete-confirm.xq?id={$id}">
                   <i class="fa fa-trash" aria-hidden="true"></i>
                </a>)
else ()
};

(:the button to edit an entry, only available for lexicon group. the name of the function is old, it does not go anymore to exide but to the update form:)

declare function app:editineXide($id as xs:string, $sources as node()) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
let $ss := for $source in $sources/source return '&amp;source' || $source/@lang ||'=' ||substring-after($source/@value, '#')
let $sourcesparam := string-join($ss, '')
(:let $base := base-uri($config:collection-root//id($id)):)
return

<a class="w3-button w3-pale-blue" href="/Dillmann/update.html?id={$id}&amp;new=false{$sourcesparam}">Update</a>
    (:,
    <a  class="w3-button w3-pale-red" href="https://betamasaheft.eu:8080/exist/apps/eXide/index.html?open={$base}">Edit XML</a>):)
)
else ()
};

(:
this function just print results from a query stored in a map. It is not used as far as I can see
declare
    %templates:default("start", 1)
function app:show-hits($node as node()*, $model as map(*), $start as xs:int) {

    for $hit at $p in subsequence($model("hits"), $start, 10)
    let $id := data($hit/@xml:id)
    let $bURI := base-uri($hit)
    return
        <div class="row" xmlns="http://www.w3.org/1999/xhtml">
            <div class="w3-quarter"><h3><a href="lemma/{$id}">{$hit/tei:form}</a></h3>{app:editineXide($bURI, <sources>{for $s in $hit/tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>
<div class="col-md-5">{transform:transform($hit/tei:sense[@xml:lang='la'], 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl', (<parameters><param name="refText" value="no"/></parameters>))}</div>
<div class="col-md-5">{transform:transform($hit/tei:sense[@xml:lang='en'], 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl', ())}</div>
        </div>
};:)

(:storing separately this input in this function makes sure that when the page is reloaded with the results the value entered remains in the input element:)
declare function app:queryinput ($node as node(), $model as map(*), $q as xs:string*){<input name="q" type="search" class="w3-twothird w3-input w3-border diacritics" placeholder="Search string" value="{$q}"/>};


(:following function is used to list all entries.
this creates an accordin with panels.
in each panel there are cards distributed on three columns with card-columns class.
the parameters, set by the form which is to be found in list-items.html allow
- to filter
    + only new entries
    + only entries with a sense with source="#traces"
- to select the language of the translations displayed

in case new is selected the full entry is shown. else only the translations because it would be otherways too much
:)
declare
    %templates:default("new", 'false()')
    %templates:default("traces", 'false()')
    %templates:default("lang", 'la')
    function app:list($node as node(), $model as map(*), $new, $traces, $lang){

<div id="accordion" class="panel-group" role="tablist" aria-multiselectable="true">
{ let $c :=  $config:collection-root
let $n := if(request:get-parameter('new', ())) then ('[descendant::tei:nd]') else ()
let $t := if(request:get-parameter('traces', ())) then ('[descendant::tei:sense[@source = "#traces"]]') else ()
let $query := '$c//tei:entry'||$n ||$t
return
         for $term in util:eval($query)

            group by $first-letter := substring($term/tei:form[1]/tei:foreign[1], 1,1)
            order by $first-letter
            return

            <div class="panel panel-default">
    <div class="panel-hading" role="tab" id="{data($first-letter)}list">

        <h3 class="mb-0" style="text-align: center;">
        <a  data-toggle="collapse" data-parent="#accordion"  href="#{data($first-letter)}letter" aria-expanded="false" aria-controls="{data($first-letter)}letter">{$first-letter}</a>
        <span class="badge">{count($term)}</span>
        </h3>
        <div id="{data($first-letter)}letter" class="collapse" role="tabpanel" aria-labelledby="{data($first-letter)}list">
        <div class="card-columns lemmas">
        {for $t in $term
        let $id := string($t/@xml:id)
        let $term-name := $t//tei:form[1]/tei:foreign[1]/text()
                let $hom:= $t//tei:form[1]/tei:seg[@type='hom']/text()
        order by $term-name
        return
               <div class="card">
               <div class="card-block" id="{data($t/@xml:id)}">
               <h4 class="card-title"><a href="lemma/{data($t/@xml:id)}">{$hom || ' '}{$term-name}</a></h4>
                {if(request:get-parameter('new', ())) then (
                let $sense := $t//tei:sense[not(@n)] return
                for $s in $sense
                order by $s/@source
                return
                <div class="card-text">
                <h4>{string($s/@xml:lang)}: </h4>
                {transform:transform($s, 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl',())}
                </div>

                ) else
                <div class="card-text">{if ($t/tei:sense[@xml:lang=$lang]//tei:cit )
                then let $citLa :=
                let $sl := $t/tei:sense[@xml:lang=$lang]
                return
                for $cit in $sl//tei:cit
                return $cit return ': ' || string-join($citLa, ', ') else ()}</div>}


                <div class="btn-group">{app:deleteEntry($id)}
                {app:editineXide($id, <sources>{for $s in $t/tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>

               </div>
               </div>
               }
      </div>
      </div>
      </div>
      </div>}
      </div>

};

(:lists all existing ref/@cRef and their corresponding abbreviation:)
declare function app:abbreviations($node as node(), $model as map(*)){

<div class="table-responsive" id="abbreviations">
<table class="table table-hover">
<thead>
<tr>
<th>Matched Reference</th>
<th>In abbreviations file</th>
<th>Proposed Abbreviation</th>
<th>Attested Abbreviation</th>
<th>Dillmann Explanation</th>
<th>Normalization</th>
<th>BM Work ID</th>
</tr>
</thead>
<tbody>
{let $refs := for $r2 in  $config:collection-root//tei:ref[@cRef]
return normalize-space(string($r2/@cRef))
         for $ref in distinct-values($refs)
         let $r := normalize-space($ref)
         let $abbreviation := $app:abbreviaturen//abbreviatur[reference = $r]

  order by $ref
         return
            <tr id="{replace($abbreviation/reference, ' ','')}">
            <td><a href="/Dillmann/search.html?ref=ref&amp;q={$ref}">{replace($r, ' ', '_')}</a></td>
            <td>{$abbreviation/reference}</td>
            <td>{$abbreviation/dillmanProposedAbk}</td>
            <td>{$abbreviation/dillmanAttestedAbk}</td>
            <td>{$abbreviation/dillmanExplanation}</td>
            <td>{$abbreviation/normalization}</td>
            <td>{$abbreviation/bmID}</td>
            </tr>
            }
            </tbody>
            </table>
      </div>

};

declare function app:citations($node as node(), $model as map(*)){
let $c :=  $config:collection-root
let $abbreviaturen := doc('../abbreviaturen.xml')
return
<div id="citationsList" class="w3-container w3-margin">
{
         for $reference in $c//tei:ref[@cRef]
            let $trimmedr := replace(replace(string($reference/@cRef),'\s+$',''),'^\s+','')
            group by $ref := $trimmedr
            order by $ref
            return
            let $abbr := $abbreviaturen//abbreviatur[reference = $ref]
            return

    <div class="row">

        <h3 class="mb-0"> {$ref} : {if($abbr) then (if($abbr/dillmanExplanation/text()) then $abbr/dillmanExplanation/text() else 'this citation is in the abbreviation list, but without explanation') else '!!! not able to find explanation in abbreviation list !!!'}</h3>

        <div>
        {for $r at $count in subsequence($reference, 1, 20)
        return

              <span> {$r/text()} in <a href="lemma/{data(root($r)//tei:entry/@xml:id)}">{root($r)//tei:form[1]/tei:foreign[1]}</a>;  </span>
             }
      </div>
      </div>}
      </div>

};

declare function app:editorNames($key as xs:string){
switch ($key)
                        case "Pietro" return 'PL'
                        case "Vitagrazia" return 'VP'
                        case "Susanne" return 'SH'
                        case "Magda" return 'MK'
                        case "Andreas" return 'AE'
                        case "Maria" return 'MB'
                        case "Wolfgang" return 'WD'
                        case "Jeremy" return 'JB'
                        case "Joshua" return 'JF'
                        case "Ralph" return 'RL'
                        case "LeonardBahr" return 'LB'
                        default return 'AB'};


(:used by revisions to print the correct name of the editor referenced in @who inside change :)
declare function app:editorKey($key as xs:string){
switch ($key)
                        case "ES" return 'Eugenia Sokolinski'
                        case "AE" return 'Andreas Ellwardt'
                        case "AE" return 'Wolfgang Dickhut'
                        case "DN" return 'Denis Nosnitsin'
                        case "MV" return 'Massimo Villa'
                        case "DR" return 'Dorothea Reule'
                        case "SG" return 'Solomon Gebreyes'
                        case "PL" return 'Pietro Maria Liuzzo'
                        case "SA" return 'Stéphane Ancel'
                        case "SD" return 'Sophia Dege'
                        case "VP" return 'Vitagrazia Pisani'
                        case "IF" return 'Iosif Fridman'
                        case "SH" return 'Susanne Hummel'
                        case "FP" return 'Francesca Panini'
                        case "DE" return 'Daria Elagina'
                        case "MB" return 'Maria Bulakh'
                        case "MK" return 'Magdalena Krzyżanowska'
                        case "VR" return 'Veronika Roth'
                        case "AA" return 'Abreham Adugna'
                        case "EG" return 'Ekaterina Gusarova'
                        case "IR" return 'Irene Roticiani'
                        case "MB" return 'Maria Bulakh'
                        case "WD" return 'Wolfgang Dickhut'
                        case "JB" return 'Jeremy Brown'
                        case "JF" return 'Joshua Falconer'
                        case "RL" return 'Ralph Lee'
                        case "LB" return 'Leonard Bahr'
                        case "CH" return 'Carsten Hoffmann'
                        default return 'Alessandro Bausi'};

(:prints the information in revisionDesc:)
declare function app:revisions($term){
       <div class="w3-panel w3-card-2 w3-pale-blue w3-hide" id="revisions">
                <ul>
                {for $change in root($term)//tei:revisionDesc/tei:change
                let $time := $change/@when
                let $author := app:editorKey(string($change/@who))
                order by $time descending
                return
                <li>
                {($author || ' ' || $change/text() || ' on ' ||  format-date($time, '[D].[M].[Y]'))}
                </li>
                }

    </ul>
    </div>};

declare function app:itemcontent ($id, $viewtype){
let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'id') then ()
                    else if ($param = 'collection') then ()
                    else if ($param = 'user') then ()
                    else if ($param = 'password') then ()
                    else
                        $param || "=" || $value,
                    "&amp;"
                )
let $col :=  $config:collection-root
let $term := $col//id($id)
let $hom := if($term//tei:form/tei:seg[@type='hom']) then concat($term//tei:form/tei:seg[@type='hom']/text(), ' ') else ()
let $rootline :=<span id="rootmembers" data-value="{$id}"/>
let $n := data($term/@n)
let $ne := xs:integer($n) + 1
let $pr := xs:integer($n) - 1
let $NE := string($ne)
let $PR := string($pr)
let $column := if($term//tei:cb) then string(($term//tei:cb/@n)[1]) else string(max($col//tei:cb[xs:integer(ancestor::tei:entry/@n) <= xs:integer($n)][@xml:id]/@n))
let $next := string($col//tei:entry[@n = $NE]/@xml:id)
let $prev := string($col//tei:entry[@n = $PR]/@xml:id)
(:        <button class="highlights btn btn-sm btn-info">Highlight/Hide strings matching the words in your search</button>:)
return
(
<div class="w3-container">

<div class="w3-col" style="width:90%">
<div class="w3-row">
      <div class="w3-third w3-bar"><span class="w3-bar-item w3-xlarge">{$hom}
      <span id="lemma"><a target="_blank" href="/Dillmann/lemma/{$id}">{let $terms := root($term)//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms}</a></span></span>
        {if($term//tei:form/tei:foreign[@xml:lang !='gez'])
        then (<sup>{string($term//tei:form/tei:foreign[@xml:lang !='gez']/@xml:lang)}</sup>) else ()}
        {$rootline}
        {if($viewtype='home') then <div class="w3-bar-item ">
<label class="switch highlights">
  <input type="checkbox"/>
  <div class="slider round" data-toggle="tooltip" title="Show or Hide highlights of each element in the entry (lemma excluded!) containing your query as a string.
  This might be different from the hits on the left, but it should help you to find your match faster."></div>
</label>
</div> else ()}
        </div>
<div class="w3-bar downloadlinks w3-twothird">
<div class="w3-bar-item">
{if($term//tei:nd) then (<span class="w3-badge w3-green w3-bar-item">New</span>) 
else(<span class="w3-badge w3-gray "><a target="_blank" 
href="{concat('http://www.tau.ac.il/~hacohen/Lexicon/pp', format-number(if(xs:integer($column) mod 2 = 1) then 
if($term//tei:cb) then (xs:integer($column)  -2) else $column else (xs:integer($column)  -1), '#'), '.html')}">
<i class="fa fa-columns" aria-hidden="true"/> {if($term//tei:cb) then (string(number(format-number($column, '#')) - 1) || '/' || format-number($column, '#')) 
else (' ' || format-number($column, '#'))}</a></span>)}
        </div>
        {app:pdf-link($id)}
        {app:getXML($id)}
        <div class="w3-right">
{app:deleteEntry($id)}
</div>
</div>

</div>
       <a class="smallArrow prev" href="{if($viewtype = 'home') then ('?'||$params||'&amp;id='||$prev) else '/Dillmann/lemma/'||$prev}">
        <i class="fa fa-chevron-left" aria-hidden="true"></i><span class="navlemma">{$col//id($prev)//tei:form/tei:foreign/text()}</span></a>{ ' | '}
<a  class="smallArrow next" data-value="{$next}" href="{if($viewtype = 'home') then ('?'||$params||'&amp;id='||$next) else '/Dillmann/lemma/'||$next}">
<span class="navlemma">{$col//id($next)//tei:form/tei:foreign/text()} </span><i class="fa fa-chevron-right" aria-hidden="true"></i></a>




 {for $sense in $term//tei:sense[not(@n)]
 let $s := (replace($sense/@source, '#', '') ||$sense/@xml:lang)
 order by $sense/@source 
return  <div class="w3-panel entry">
<h3>
{if($sense/@source = '#traces') then 'TraCES' else 'Dillmann'}
{if($sense/@source) then (let $s := substring-after($sense/@source, '#') 
return <a href="#" class="w3-tooltip">
<i class="fa fa-info-circle" aria-hidden="true"></i>
<span class="w3-text">{root($term)//tei:sourceDesc//tei:ref[@xml:id=$s]//text()}, {
switch($sense/@xml:lang) case 'la' return 'Latin' case 'ru' return 'Russian' case 'en' return 'English' case 'de' return 'Deutsch'
case 'it' return 'Italian' default return string($sense/@xml:id)}</span>
</a>) else ()}
</h3>
<div>
<a class="w3-right w3-button w3-tiny w3-gray" onclick="toggletabletextview('{$s}')">Table/Text</a>
<div id="{$s}">
<div class="w3-show" id="textView{$s}">
{transform:transform($sense, 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl',())}
</div>
<div class="w3-hide" id="tabularView{$s}">
{transform:transform($sense, 'xmldb:exist:///db/apps/gez-en/xslt/table.xsl',())}
</div>
</div>
</div>
</div>}


      <div class="w3-bar">
      <a class="w3-bar-item w3-button w3-pale-green" onclick="togglElements('revisions')">Revisions</a>
      {app:editineXide($id, <sources>{for $s in $term/tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}
   <a class="w3-bar-item w3-button w3-green" target="_blank" href="mailto:pietro.liuzzo@uni-hamburg.de?Subject=[Dillmann]%20{$id}">
   <i class="fa fa-envelope-o" aria-hidden="true"></i>
</a></div>
{app:revisions($term)}


<div>

    </div>

</div>
<div class="w3-rest">
 <div id="showroot"/>
</div>
    </div>,
    <div class="w3-panel">
    
        <h3><span id='NumOfAtt'/> Attestations in the Beta maṣāḥǝft corpus</h3>
    <span class="w3-button w3-green" id="loadattestations">Load</span>
    <div id="attestations" />
    </div>)
};


(:print the entry, transforming with xsl the contents and preparing the html for further dispaly rework done in videas.js :)
declare function app:item($node as node(), $model as map(*)){
let $col :=  $config:collection-root
let $id := request:get-parameter("id", "")
return app:itemcontent($id, 'item')
};


(:print the entry in the main landing page, transforming with xsl the contents and preparing the html for further dispaly rework done in videash.js
the difference from the previous function is in that here parameters need to be taken into account. It has also a switch, which is not in the main view, which higlights the terms from teh search
:)
declare function app:showitem($node as node()*, $model as map(*), $id as xs:string?){
if ($id) then (
    app:itemcontent($id, 'home')
)
else (<div class="w3-panel w3-card-4 w3-sand w3-margin w3-paddgin-64">Search and click on a search result to see it here. You will be able to click on words, browse the previous and next entries, get the result on its own page and see related finds from Beta maṣāḥǝft.</div>)};



declare  %templates:wrap function app:editedItem($node as node()*, $model as map(*)){
let $new := request:get-parameter('new', '')
let $id := request:get-parameter('id', '')
let $data-collection := '/db/apps/DillmannData/'

let $file := if ($new='true') then
        'new-instance.xml'
    else
         $config:collection-root//id($id)
return map {'file' := $file,
'id' := $id}
};


declare function app:tempNew($node as node()*, $model as map(*)){
<div class="w3-container w3-margin">
    <h3>Templates</h3>
    <div class="w3-half">
    <p>You are creating a new entry. Please, make sure it has at least these elements:
                </p>
                <ul>
                <li>Graphic Variants if any;</li>
                <li>Transliteration;</li>
                <li>Translation; </li>
                <li>Reference to the source of the translation if available;</li>
                <li>Part of speech (if different from those already in Dillmann).</li>
                </ul>
                </div>
                <div class="w3-half">
                <p>Here is a template for a new english entry with an english translation, which you can copy and paste in the editor.</p>
                <p><pre>
                &lt;Sen&lt;
                or \*gez*  \*
                &gt;gez!  &gt;
                &gt;en&gt;   &gt;
                [  ,  ]bm:
                {{ND}}
                &gt;S&gt;
                </pre></p>

                </div>
    </div>
};

declare function app:newForm ($node as node()*, $model as map(*)){
 <form id="createnew" action="/Dillmann/edit/save-new-entity.xql" method="post" class="w3-container w3-padding">
             <div class="w3-container">
            <label for="form" class="w3-quarter">Lemma</label>
            <div class="w3-threequarter w3-bar">
            <input class="w3-input w3-bar-item w3-border" id="form" name="form" required="required" value="{if(request:get-parameter('form',())) then request:get-parameter('form',()) else ()}"/>
                <select class="w3-bar-item w3-select w3-border" id="formlang" name="formlang" required="required">
                <option value="gez" selected="selected">Gǝʿǝz</option>
                <option value="amh">Amharic</option>
                <option value="ti">Tigrinya</option>
                <option value="so">Somali</option>
                </select>
                <small class="w3-small w3-bar-item">select the language of the entry</small>
            </div>
            </div>
             <div class="w3-container">
            <label for="form" class="w3-quarter">Lemma</label>
            <div class="w3-threequarter"  id="checkifitalreadyexists"><div class="w3-panel w3-lightygreen w3-card-2">Please paste or write something above and I will tell you if it is already in.</div></div>
            </div>
     
        <div class="w3-container">
            <label for="source" class="w3-quarter">Source</label>
            <div class="w3-threequarter w3-bar">
                <select class="w3-select w3-border w3-bar-item" id="sourceen" name="sourceen" required="required">
                <option value="dillmann">Dillmann</option>
                <option value="traces">TraCES</option>
                </select>
                <small class="w3-small w3-bar-item">type here the new Gǝʿǝz form to be added</small>
            </div>
        </div>

        <div class="w3-container">
            <label for="senseen" class="w3-quarter">Sense</label>
            <div class="w3-threequarter">
            {app:buttons('en')}
                <textarea class="w3-input w3-border" id="senseen"
                name="senseen"  style="height:250px;">{if(request:get-parameter('senseen',())) then request:get-parameter('senseen',()) else ('<Sen<   {ND} >S>')}</textarea>
                <small class="w3-small">type here your definition, following the guidelines below.</small>
            </div>
        </div>
        <div id="addsense"></div>
        <button class="w3-button w3-green add_field_button">Add More Meanings</button>

       <div class="w3-container w3-card-2 w3-margin w3-padding-64">

            <label for="msg" class="w3-quarter" >What have you done?</label>
            <div class="w3-threequarter">
                <textarea class="w3-input w3-border" id="msg" name="msg" required="required">{if(request:get-parameter('msg',())) then request:get-parameter('msg',()) else ()}</textarea>
                <small class="w3-small">shortly describe the changes you have made</small>
            </div>
       
        <div class="w3-container">
        <div class="w3-quarter"><button id="confirmcreatenew" type="submit" class="w3-button w3-green">Confirm (or lose all)</button></div>
        <div class="w3-threequarter">
    <input type="checkbox" class="w3-check" id="notifyEditors" name="notifyEditors" value="yes"/>
    <label for="notifyEditors">Send an email to the editors about this change</label>
  </div>
 </div>
 </div>
    </form>
};

declare function app:updateFormGroup($sense){
let $lang := string($sense/@xml:lang)
let $paramname := 'sense' || $lang
let $existingsource := 'source' || $lang
let $parexistingsource := request:get-parameter($existingsource, ())
let $source := if($sense/@source) then string($sense/@source) else ' (' || app:switchLangName($sense) || ')'
return
<div>
<div class="w3-container">
            <label for="source{$lang}" class="w3-quarter">Source of {'Sense' || $source}</label>
            <div class="w3-threequarter w3-bar">
                <select class="w3-select w3-border w3-bar-item" id="source{$lang}" name="source{$lang}" required="required">
                <option value="dillmann">
                {if($parexistingsource = 'dillmann') then(attribute selected{'selected'}) else ()}
                Dillmann
                </option>
                <option value="traces">
                {if($parexistingsource = 'traces') then(attribute selected{'selected'}) else ()}
                TraCES
                </option>
                </select>
                <small class="w3-small w3-bar-item">type here the new Gǝʿǝz form to be added</small>
            </div>
        </div>
 <div class="w3-container">

            <label for="sense{$lang}" class="w3-quarter">{'Sense' || $source}</label>
            <div class="w3-threequarter">
            {app:buttons($lang)}
            <div id="wrap">
                <textarea class="w3-input w3-border" id="sense{$lang}" name="sense{$lang}" style="height:250px;">{if(request:get-parameter($paramname,())) then request:get-parameter($paramname,()) else transform:transform($sense, 'xmldb:exist:///db/apps/gez-en/xslt/xml2editor.xsl', ())}</textarea>
             </div>
             <small class="w3-small">type here your latin definition</small>
            </div>
        </div>
        <a href="#" class="w3-button w3-small w3-red">Remove {$lang} meaning permanently</a>
        </div>

};

declare function app:update ($node as node()*, $model as map(*)) {

let $id := $model('id')
let $file := $model('file')
(:this will match tei:entry:)

return

               ( <h2>Edit Entry</h2>,
           <div class="w3-panel w3-card-2"><p>Hi {xmldb:get-current-user()}! You are updating {$file//tei:form/tei:foreign/text()}, that is great!</p>
           <p> Please follow the data entry support on the side of this form for editing the entries.</p>
           <p> Remember, you are here editing the dictionaries as sources of information, not annotating texts. The structure given to the entries is useful for many purposes.</p></div>,
                <form id="updateEntry" action="/Dillmann/edit/edit.xq" class="w3-container w3-padding input_fields_wrap" method="post">
                <input hidden="hidden" value="{$id}" name="id"/>
                   <div class="w3-container">
            <label for="form" class="w3-quarter col-form-label">Lemma</label>
            <div class="w3-threequarter w3-bar">
           
            <div  class="w3-bar-item w3-bar">
                <input class="w3-input w3-border w3-bar-item diacritics" id="senselemma" name="form" value="{$file//tei:form/tei:foreign/text()}"/>
              <a class="iconlemma kb w3-button w3-pale-green w3-bar-item">
                                <i class="fa fa-keyboard-o" aria-hidden="true"></i>
                                </a>
            </div>
            <small class="w3-small">you can correct here the Gǝʿǝz form. Simply type it.</small>
           
             <input class="w3-check w3-bar-item" type="checkbox" id="rootCheck" name="root" value="root">
                {if($file//tei:form/tei:rs[@type]) then attribute checked {'checked'} else ()}
                </input>
            <div class="w3-bar-item" >
                <select class="w3-select w3-border w3-bar-item" id="formlang" name="formlang" required="required">
                <option value="gez" selected="selected">Gǝʿǝz</option>
                <option value="amh">Amharic</option>
                <option value="ti">Tigrinya</option>
                <option value="so">Somali</option>
                </select>
            </div> 
            </div>
        </div>



        {for $sense in $file//tei:sense[@xml:lang][@n='S' or not(@n)]
        return app:updateFormGroup($sense)}
        <div id="addsense"></div>
        <button class="w3-button w3-green add_field_button">Add More Meanings</button>

        <div class="w3-container w3-card-2 w3-margin w3-padding-64">

            <label for="msg" class="w3-quarter" >What have you done?</label>
            <div class="w3-threequarter">
                <textarea class="w3-input w3-border" id="msg" name="msg" required="required">{if(request:get-parameter('msg',())) then request:get-parameter('msg',()) else ()}</textarea>
                <small class="w3-small">shortly describe the changes you have made</small>
            </div>
       
        <div class="w3-container">
        <div class="w3-quarter"><button id="confirmcreatenew" type="submit" class="w3-button w3-green">Confirm (or lose all)</button></div>
        <div class="w3-threequarter">
    <input type="checkbox" class="w3-check" id="notifyEditors" name="notifyEditors" value="yes"/>
    <label for="notifyEditors">Send an email to the editors about this change</label>
  </div>
 </div> 
 </div>
                </form>

                )

};




declare function app:buttons($name){
<div class="w3-bar"><a id="{$name}NestSense" class="w3-button w3-xsmall w3-blue">Meaning</a>
            <a id="{$name}translation" class="w3-button w3-xsmall w3-blue">Translation</a>
            <a id="{$name}transcription" class="w3-button w3-xsmall w3-blue">Transcription</a>
            <a id="{$name}PoS" class="w3-button w3-xsmall w3-blue">PoS</a>
            <a id="{$name}reference" class="w3-button w3-xsmall w3-blue">Reference</a>
            <a id="{$name}bibliography" class="w3-button w3-xsmall w3-blue">Bibliography</a>
            <a id="{$name}otherLanguage" class="w3-button w3-xsmall w3-blue">Language</a>
            <a id="{$name}internalReference" class="w3-button w3-xsmall w3-blue">Internal Reference</a>
            <a id="{$name}gramGroup" class="w3-button w3-xsmall w3-blue">Grammar Group</a>
            <a id="{$name}label" class="w3-button w3-xsmall w3-blue">Label</a>
            <a id="{$name}case" class="w3-button w3-xsmall w3-blue">Case</a>
            <a id="{$name}gen" class="w3-button w3-xsmall w3-blue">Gender</a>
            <a id="{$name}ND" class="w3-button w3-xsmall w3-blue">ND</a>
         </div>
};
declare function app:upconvertSense($senseAndSource) as node(){

let $newTextsource := $senseAndSource/source
let $newText := $senseAndSource/sense
let $newsense := transform:transform(<node>{$newText}</node>, 'xmldb:exist:///db/apps/gez-en/xslt/upconversion.xsl', <parameters>
    <param name="source" value="{$newTextsource}"/>
</parameters>)
return
$newsense
};

declare function app:DoUpdate($node as node()*, $model as map(*)){
let $parametersName := request:get-parameter-names()
let $cU := xmldb:get-current-user()
let $file := $model('file')
let $id := $model('id')
let $msg := request:get-parameter('msg', ())
let $title := 'Update Confirmation'
let $data-collection := '/db/apps/DillmannData'
let $record :=  $config:collection-root//id($id)
let $rootitem := root($record)//tei:TEI
let $backup-collection := '/db/apps/gez-en/EditorBackups/'
let $targetfileuri := base-uri($record)
let $filename := $file//tei:form/tei:foreign/text()

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
let $form := $record//tei:form//tei:foreign//text()
return
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
                       <authority>Hiob-Ludolf-Zentrum für Äthiopistik</authority>
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
                    {for $s in $eachsense//tei:sense return $s}
                </entry>
                </div>
               </body>
            </text>
        </TEI>

let $schema := doc('/db/apps/gez-en/schema/Dillmann.rng')
            let $validation := validation:jing($temporary, $schema)
            return
            if($validation = true()) then (
let $doc := doc($targetfileuri)
let $sensesArray := $doc//tei:sense
let $sensesLang := for $lang in $sensesArray/@xml:lang return $lang
let $eachLang := for $lang in $eachsense//tei:sense/@xml:lang return $lang

let $updateform :=  for $s in $eachsense//tei:sense
let $slang := string($s/@xml:lang)

return
if($sensesArray[@xml:lang = $slang])
then( update replace $sensesArray[@xml:lang=$slang] with $s)
else (update insert $s into $doc//tei:entry)

let $deleteRemoved := for $removedLang in distinct-values($sensesLang[not(.=$eachLang)])
return
    update delete $sensesArray[@xml:lang=$removedLang]


let $change := <change xmlns="http://www.tei-c.org/ns/1.0" who="{switch(xmldb:get-current-user()) case 'Pietro' return 'PL' case 'Vitagrazia' return 'VP' case 'Alessandro' return 'AB' default return 'AE'}" when="{format-date(current-date(), "[Y0001]-[M01]-[D01]")}">{$msg}</change>
let $updateChange := update insert $change into doc($targetfileuri)//tei:revisionDesc

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
                  <p>{transform:transform($rootitem, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</p>
                  <p><a href="{$config:appUrl}/Dillmann/lemma/{$id}"
                  target="_blank">See {$filename} online!</a> There you can also update the file again.</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
mail:send-email($contributorMessage, 'public.uni-hamburg.de', ())

  ,

  let $EditorialBoardMessage := <mail>
    <from>pietro.liuzzo@uni-hamburg.de</from>
    <to>susanne.hummel@uni-hamburg.de</to>
    <to>vitagrazia.pisani@gmail.com</to><to>wolfgang.dickhut@gmail.com</to>
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
                  <p>{$cU} said he: {$msg} in this file</p>
                  <p>This is how it looks like in txt now:</p>
                  <p>{transform:transform($rootitem, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</p>
                  <p><a href="{$config:appUrl}/Dillmann/lemma/{$id}"
                  target="_blank">See {$filename} online!</a> There you can also update the file again.</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>
return
mail:send-email($EditorialBoardMessage, 'public.uni-hamburg.de', ())
)
return
<div class="alert alert-success">
    <h2>{$title}</h2>
    <p class="lead">Dear {$cU}, Lemma  <a href="/Dillmann/lemma/{$id}">{$filename}</a> has been updated successfully!</p>
   <p>A notification email has been sent to the editors.</p>
   <p class="lead">Thank you!</p>
  </div>
  )
  else (
  <div class="w3-container w3-margin w3-panel w3-lightyellow w3-card-2">

  <p class="lead">Sorry, the document you are trying to save is not valid.
  There is probably an error in the content somewhere. Below you can see the report from the schema and the XML produced: check it out or send the link or a screenshoot to somebody for help.</p>
                <pre>{validation:jing-report($temporary, $schema)}</pre>
                <div id="editorContainer"><div id="ACEeditor">{$temporary//tei:entry}</div></div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.6/ace.js" type="text/javascript" charset="utf-8"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.6/ext-language_tools.js" type="text/javascript" charset="utf-8"></script>

<script src="resources/js/ACEsettings.js"/>

</div>
  )

  ) else()
};
declare function app:switchLangName ($nodewithlang) as xs:string {
switch($nodewithlang/@xml:lang)
case 'la' return 'Latin'
case 'en' return 'English'
case 'de' return 'Deutsch'
case 'it' return 'Italian'
default return $nodewithlang/@xml:id};


declare function app:repl($query, $match, $sub)
{
(: take the string and make into a sequence eg. abcabc   :)
    let $seq :=
        for $ch in string-to-codepoints($query)
        return codepoints-to-string($ch)
(:        loop the sequence (a,b,c,a,b,c):)
    for $x in $seq
(:    get the position of the character in the sequence, a = (0, 3):)
    return
        if ($x = $match) then
         let $index := index-of($seq, $x)
         return
(:    loop each occurrence of that character to do the substitutions one by one in case it matches, 0 and 3 for the example:)
    for $i in $index

    return
(:        substitute only that occurence by removing it and adding the substitute in its place, so in the first loop, remove a and then add d before position 0:)
            let $rem := remove($seq, $i)
            let $add := insert-before($rem, $i, $sub)
            let $newstring := string-join($add, '')
(:          returns the string dbcabc and sends the same over again to this template.  :)
            return
           ($newstring,
           app:repl($newstring, $match, $sub))

        else
(:          there character does not match and the string is returned  :)
            string-join($seq, '')

(:            this generates an exponential number of options which are the same, but can then be filtered with distinct-values() :)
};

declare function app:subs($query, $homophones, $mode) {
    let $all :=
    for $b in $homophones
    return
    for $q in $query return
        if (contains($q, $b)) then
            let $options := for $s in $homophones[. != $b]
            return
                (distinct-values(app:repl($q, $b, $s)),
                if ($mode = 'ws') then
                    (replace($q, $b, ''))
                else
                    ())
             let $checkedoptions := for $o in $options return
             if ($o = $query) then () else $o
            return
                $checkedoptions
        else
            ()
   let $queryAndAll := ($query, $all)
   return distinct-values($queryAndAll)
};


declare function app:substitutionsInQuery($query as xs:string*) {
    let $query-string := normalize-space($query)
    let $emphaticS := ('s','s', 'ḍ')
    let $query-string := app:subs($query-string, $emphaticS, 'normal')
        let $e := ('e','ǝ','ə','ē')
    let $query-string := app:subs($query-string, $e, 'normal')
    (:Remove/ignore ayn and alef  and search for both:)

     let $Ww:= ('w','ʷ')
    let $query-string := app:subs($query-string, $Ww, 'normal')

    let $aleph := ('ʾ', 'ʿ')
    let $alay := ('`', 'ʾ', 'ʿ')
    let $query-string := app:subs($query-string, $aleph, 'ws')
    let $query-string := app:subs($query-string, $alay, 'ws')

    (:  substitutions of omophones:)
    let $laringals14 := ('ሀ', 'ሐ', 'ኀ', 'ሃ', 'ሓ', 'ኃ')
    let $query-string := app:subs($query-string, $laringals14, 'normal')


    let $laringals2 := ('ሀ', 'ሐ', 'ኀ')
    let $query-string := app:subs($query-string, $laringals2, 'normal')
    let $laringals3 := ('ሂ', 'ሒ', 'ኂ')
    let $query-string := app:subs($query-string, $laringals3, 'normal')
    let $laringals4 := ('ሁ', 'ሑ', 'ኁ')
    let $query-string := app:subs($query-string, $laringals4, 'normal')
    let $laringals5 := ('ሄ', 'ሔ', 'ኄ')
    let $query-string := app:subs($query-string, $laringals5, 'normal')
    let $laringals6 := ('ህ', 'ሕ', 'ኅ')
    let $query-string := app:subs($query-string, $laringals6, 'normal')
    let $laringals7 := ('ሆ', 'ሖ', 'ኆ')
    let $query-string := app:subs($query-string, $laringals7, 'normal')


  let $ssound := ('ሠ','ሰ')
    let $query-string :=   app:subs($query-string, $ssound, 'normal')
  let $ssound2 := ('ሡ','ሱ')
    let $query-string :=   app:subs($query-string, $ssound2, 'normal')
  let $ssound3 := ('ሢ','ሲ')
    let $query-string :=   app:subs($query-string, $ssound3, 'normal')
  let $ssound4 := ('ሣ','ሳ')
    let $query-string :=   app:subs($query-string, $ssound4, 'normal')
  let $ssound5 := ('ሥ','ስ')
    let $query-string :=   app:subs($query-string, $ssound5, 'normal')
  let $ssound6 := ('ሦ','ሶ')
    let $query-string :=   app:subs($query-string, $ssound6, 'normal')
  let $ssound7 := ('ሤ','ሴ')
    let $query-string :=   app:subs($query-string, $ssound7, 'normal')

        let $emphaticT1 := ('ጸ', 'ፀ')
    let $query-string := app:subs($query-string, $emphaticT1, 'normal')
       let $emphaticT2 := ('ጹ', 'ፁ')
    let $query-string := app:subs($query-string, $emphaticT2, 'normal')
        let $emphaticT3 := ('ጺ', 'ፂ')
    let $query-string := app:subs($query-string, $emphaticT3, 'normal')
        let $emphaticT4 := ('ጻ', 'ፃ')
    let $query-string := app:subs($query-string, $emphaticT4, 'normal')
        let $emphaticT5 := ('ጼ', 'ፄ')
    let $query-string := app:subs($query-string, $emphaticT5, 'normal')
        let $emphaticT6 := ('ጽ', 'ፅ')
    let $query-string := app:subs($query-string, $emphaticT6, 'normal')
        let $emphaticT7 := ('ጾ', 'ፆ')
    let $query-string := app:subs($query-string, $emphaticT7, 'normal')

      let $asounds14 :=   ('አ', 'ዐ', 'ኣ', 'ዓ')
    let $query-string := app:subs($query-string, $asounds14, 'normal')

    let $asounds2 := ('ኡ', 'ዑ')
    let $query-string := app:subs($query-string, $asounds2, 'normal')
    let $asounds3 := ('ኢ', 'ዒ')
    let $query-string := app:subs($query-string, $asounds3, 'normal')
    let $asounds5 := ('ኤ', 'ዔ')
    let $query-string := app:subs($query-string, $asounds5, 'normal')
    let $asounds6 := ('እ', 'ዕ')
    let $query-string := app:subs($query-string, $asounds6, 'normal')
    let $asounds7 := ('ኦ', 'ዖ')
    let $query-string := app:subs($query-string, $asounds7, 'normal')


    return
        string-join($query-string, ' ')

};


declare function app:buildqueryparts($parName, $attName, $not, $el){
let $parameterslist := request:get-parameter-names()
return
if (contains($parameterslist, $parName))
                then
                let $lp := request:get-parameter($parName, ())
                let $lpvals:= for $slp in $lp return if($attName="value") then ( 'text()' || "='"|| $slp || "'") else ( "@" ||$attName || "='"|| $slp || "'")
                let $val := if(count($lpvals) gt 1) then string-join($lpvals, ' or ') else $lpvals
                return if(contains($parameterslist, $not))
                then ("[not(descendant::tei:"||$el||"[" ||$val ||  "])]")
                else ("[descendant::tei:"||$el||"[" ||$val ||  "]]")
                else ()
};

declare %templates:wrap
    %templates:default("mode", "none")
function app:AdvQuery(
$node as node()*,
$model as map(*),
$q as xs:string*){
let $parameterslist := request:get-parameter-names()
return
if(empty($parameterslist)) then () else
let $data-collection := '/db/apps/DillmannData'
let $coll :=  $config:collection-root
let $l := app:buildqueryparts('languages', "xml:lang", 'notlang', 'foreign')

let $c := app:buildqueryparts('case', "value", 'notcase', 'case')

let $p := app:buildqueryparts('pos', "expand", 'notpos', 'pos')

let $lbl := app:buildqueryparts('lbl', "expand", 'notlbl', 'lbl')

let $g := app:buildqueryparts('gender', "value", 'notgender', 'gen')

let $qtext := if(empty($q)) then () else app:substitutionsInQuery($q)

let $options :=
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>


let $query := if(empty($q) or $q = '') then ('$coll//tei:entry' || $c ||$l ||$p) else ('$coll//tei:entry[ft:query(*, $qtext, $options)]' ||$c || $l ||$p)

let $hits := for $hit in util:eval($query) return $hit
return
 map {"hits" := $hits}

};

declare %templates:wrap
    %templates:default("mode", "none")
function app:query($node as node()*, $model as map(*), $q as xs:string?, $ref as xs:string?, $mode as xs:string){
let $cun := request:get-parameter('GtC', ())

let $l := app:buildqueryparts('languages', "xml:lang", 'notlang', 'foreign')

let $c := app:buildqueryparts('case', "value", 'notcase', 'case')

let $p := app:buildqueryparts('pos', "expand", 'notpos', 'pos')

let $lbl := app:buildqueryparts('lbl', "expand", 'notlbl', 'lbl')

let $g := app:buildqueryparts('gender', "value", 'notgender', 'gen')

let $subc := app:buildqueryparts('subc', "value", 'notsubc', 'subc')

let $erw := $l || $c || $p || $lbl || $g || $subc

let $data-collection := '/db/apps/DillmannData'
let $coll := $config:collection-root
return

if(empty($q)) then (
if($cun) then (
let $formatCun := format-number($cun, '0000')

let $hits := for $hit in $coll//tei:entry//tei:cb[@n=$formatCun] return $hit

return
  map {"hits" := $hits}
)
else ()

) else (

if($mode='none') then

if($ref = 'ref')
then(

let $hits := for $hit in $coll//tei:entry//tei:ref[@cRef=$q] return $hit
return
  map {"hits" := $hits}
)
else if($ref = 'addenda')
then(

let $hits := for $hit in $coll//tei:entry//tei:ref[contains(@target, $q)] return $hit
return
  map {"hits" := $hits}
)
else(
let $qtext := if(empty($q)) then () else app:substitutionsInQuery($q)

let $options :=
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
return

let $qp := if(empty($q) or $q = '') then ('$coll//tei:entry' || $erw) else '$coll//tei:entry[ft:query(*, $qtext, $options)]' || $erw

let $hits := for $hit in util:eval($qp) let $sorting := if(empty($q) or $q = '') then $hit//tei:form[1]/tei:foreign[1]/text()[1] else ft:score($hit) order by $sorting descending return $hit
return
  map {"hits" := $hits,
  "query":=$qp}
  )



 else(

  let $queryExpr := app:create-query($q, $mode)
  let $qp := '$coll//tei:entry[ft:query(*, $queryExpr)]'  || $erw
  let $hits := for $hit in util:eval($qp)
                    order by ft:score($hit) descending
                    return $hit
   return
                (: Process nested templates :)
                map {
                    "hits" := $hits,
                    "query" := $queryExpr
                }

 ))

};


declare
    %templates:wrap function app:advhit-count($node as node()*, $model as map(*)) {
    <h3>You found  <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ count($model("hits")) }</span> entries!</h3>

};

declare
    %templates:wrap function app:hit-count($node as node()*, $model as map(*)) {
    let $q := request:get-parameter('q',())
    return
    if(empty($q)) then () else
    <h3>You found "{$q}" in <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ count($model("hits")) }</span> entries!</h3>

};

declare
    %templates:wrap function app:biblio-count($node as node()*, $model as map(*)) {
    <h3>There are <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ $model("total") }</span> distinc bibliographical sources.</h3>

};


(:~
 : FROM SHAKESPEAR
    Create a span with the number of items in the current search result.
:)

declare %private function app:create-query($query-string as xs:string?, $mode as xs:string) {

    let $query-string :=
        if ($query-string)
        then app:sanitize-lucene-query($query-string)
        else ''

    let $query-string := normalize-space($query-string)
    let $query:=
        (:If the query contains any operator used in sandard lucene searches or regex searches, pass it on to the query parser;:)
        if (functx:contains-any-of($query-string, ('AND', 'OR', 'NOT', '+', '-', '!', '~', '^', '.', '?', '*', '|', '{','[', '(', '<', '@', '#', '&amp;')) and $mode eq 'any')
        then
            let $luceneParse := app:parse-lucene($query-string)

            let $luceneXML := util:parse($luceneParse)
            let $lucene2xml := app:lucene2xml($luceneXML/node(), $mode)
            return $lucene2xml
        (:otherwise the query is performed by selecting one of the special options (any, all, phrase, near, fuzzy, wildcard or regex):)
        else
            let $query-string := tokenize($query-string, '\s')

            let $last-item := $query-string[last()]
            let $query-string :=  string-join($query-string, ' ')

           let $query :=
                <query>
                    {
                        if ($mode eq 'any')
                        then
                            for $term in tokenize($query-string, '\s')
                            return <term occur="should">{$term}</term>
                        else if ($mode eq 'all')
                        then
                            <bool>
                            {
                                for $term in tokenize($query-string, '\s')
                                return <term occur="must">{$term}</term>
                            }
                            </bool>
                        else
                            if ($mode eq 'phrase')
                            then <phrase>{$query-string}</phrase>
                            else
                                if ($mode eq 'near-unordered')
                                then <near slop="{if ($last-item castable as xs:integer) then $last-item else 5}" ordered="no">{$query-string}</near>
                                else
                                    if ($mode eq 'near-ordered')
                                    then <near slop="{if ($last-item castable as xs:integer) then $last-item else 5}" ordered="yes">{$query-string}</near>
                                    else
                                        if ($mode eq 'fuzzy')
                                        then <fuzzy max-edits="{if ($last-item castable as xs:integer and number($last-item) < 3) then $last-item else 2}">{$query-string}</fuzzy>
                                        else
                                            if ($mode eq 'wildcard')
                                            then <wildcard>*{$query-string}*</wildcard>
                                            else
                                                if ($mode eq 'regex')
                                                then <regex>{$query-string}</regex>
                                                else ()
                    }</query>
            return $query
    return $query

};
(:~
 : FROM SHAKESPEAR
 : Create a bootstrap pagination element to navigate through the hits.
 :)


declare
    %templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 20)
    %templates:default("min-hits", 0)
    %templates:default("max-pages", 20)
function app:paginate($node as node(), $model as map(*), $start as xs:int, $per-page as xs:int, $min-hits as xs:int,
    $max-pages as xs:int) {

    if ($min-hits < 0 or count($model("hits")) >= $min-hits) then
        let $count := xs:integer(ceiling(count($model("hits"))) div $per-page) + 1
        let $middle := ($max-pages + 1) idiv 2
        let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'collection') then ()
                    else if ($param = 'user') then ()
                    else if ($param = 'password') then ()
                    else if ($param = 'start') then ()
                    else
                        $param || "=" || $value,
                    "&amp;"
                )
        return (
            if ($start = 1) then (
                 <a class="w3-button w3-disabled"><i class="fa fa-fast-backward"></i></a>,
               
                    <a class="w3-button w3-disabled"><i class="fa fa-backward"></i></a>
            ) else (
<a href="?{$params}&amp;start=1" class="w3-button "><i class="fa fa-fast-backward"></i></a>
                ,
                    <a href="?{$params}&amp;start={max( ($start - $per-page, 1 ) ) }" class="w3-button "><i class="fa fa-backward"></i></a>
                            ),
            let $startPage := xs:integer(ceiling($start div $per-page))
            let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
            let $upperBound := min(($lowerBound + $max-pages - 1, $count))
            let $lowerBound := max(($upperBound - $max-pages + 1, 1))
            for $i in $lowerBound to $upperBound
            return
                if ($i = ceiling($start div $per-page)) then
                   <a class="w3-button" href="?{$params}&amp;start={max( (($i - 1) * $per-page + 1, 1) )}">{$i}</a>
                else
                    <a class="w3-button" href="?{$params}&amp;start={max( (($i - 1) * $per-page + 1, 1)) }">{$i}</a>,
           if ($start + $per-page < count($model("hits"))) then (
                  <a  class="w3-button" href="?{$params}&amp;start={$start + $per-page}"><i class="fa fa-forward"></i></a>
                ,
                    <a  class="w3-button" href="?{$params}&amp;start={max( (($count - 1) * $per-page + 1, 1))}"><i class="fa fa-fast-forward"></i></a>
                ) else (
                  <a class="w3-button w3-disabled"><i class="fa fa-forward"></i></a>,
                <a class="w3-button w3-disabled"><i class="fa fa-fast-forward"></i></a>)
        ) else
            ()
};



declare
%templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 10)
    function app:searchRes (
    $node as node(),
    $model as map(*), $start as xs:integer, $per-page as xs:integer) {

    for $term at $p in subsequence($model("hits"), $start, $per-page)
        let $id := root($term)//tei:entry/@xml:id
              let $term-name := let $terms := root($term)//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms
              order by ft:score($term) descending

          return
            <div class="w3-row reference ">
               <div class="w3-third"><a href="lemma/{data($id)}">{$term-name}</a></div>
               <div class="w3-third">{kwic:summarize($term,<config width="40"/>)}</div>
               <div class="w3-quarter"><code>{$term/name()}</code></div>
               <div class="w3-quarter">{app:editineXide($id, <sources>{for $s in root($term)//tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>
            </div>





    };

    declare
%templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 10)
    function app:fullRes (
    $node as node(),
    $model as map(*), $start as xs:integer, $per-page as xs:integer) {
         let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'id') then ()
                    else  if ($param = 'user') then ()
                    else  if ($param = 'password') then ()
                    else if ($param = 'collection') then ()
                    else
                        $param || "=" || $value,
                    "&amp;"
                )
    for $term at $p in subsequence($model("hits"), $start, $per-page)
    let $expanded := kwic:expand($term)
        let $id := root($term)//tei:entry/@xml:id
              let $term-name := let $terms := root($term)//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms
              let $hom := if(root($term)//tei:form/tei:seg[@type='hom']) then concat(root($term)//tei:form/tei:seg[@type='hom']/text(), ' ') else ()
              order by ft:score($term) descending
          return
          
          <div class="w3-row row">
            <div class="w3-quarter">
            <div class="w3-twothird"><a class="w3-button w3-blue" href="?{$params}&amp;id={data($id)}">{$hom || $term-name}</a></div>
            <div class="w3-third"><span class="w3-badge"> {count($expanded//exist:match)}</span></div>
            </div>
             <div class="w3-threequarter">
             <div class="w3-threequarter">{for $match in subsequence($expanded//exist:match, 1, 3) return  kwic:get-summary($expanded, $match,<config width="40"/>)}</div>
             <div class="w3-quarter">{app:editineXide($id, <sources>{for $s in root($term)//tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>
             </div>

        </div>





    };


(: copy all parameters, needed for search :)
declare function app:copy-params($node as node(), $model as map(*)) {
    element { node-name($node) } {
        $node/@* except $node/@href,
        attribute href {
            let $link := $node/@href
            let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'user') then ()
                    else  if ($param = 'password') then ()
                    else

                        $param || "=" || $value,
                    "&amp;"
                )
            return
                $link || "?" || $params
        },
        $node/node()
    }
};


(: This functions provides crude way to avoid the most common errors with paired expressions and apostrophes. :)
(: TODO: check order of pairs:)
declare %private function app:sanitize-lucene-query($query-string as xs:string) as xs:string {
    let $query-string := replace($query-string, "'", "''") (:escape apostrophes:)
    (:TODO: notify user if query has been modified.:)
    (:Remove colons – Lucene fields are not supported.:)
    let $query-string := translate($query-string, ":", " ")
    let $query-string :=
	   if (functx:number-of-matches($query-string, '"') mod 2)
	   then $query-string
	   else replace($query-string, '"', ' ') (:if there is an uneven number of quotation marks, delete all quotation marks.:)
    let $query-string :=
	   if ((functx:number-of-matches($query-string, '\(') + functx:number-of-matches($query-string, '\)')) mod 2 eq 0)
	   then $query-string
	   else translate($query-string, '()', ' ') (:if there is an uneven number of parentheses, delete all parentheses.:)
    let $query-string :=
	   if ((functx:number-of-matches($query-string, '\[') + functx:number-of-matches($query-string, '\]')) mod 2 eq 0)
	   then $query-string
	   else translate($query-string, '[]', ' ') (:if there is an uneven number of brackets, delete all brackets.:)
    let $query-string :=
	   if ((functx:number-of-matches($query-string, '{') + functx:number-of-matches($query-string, '}')) mod 2 eq 0)
	   then $query-string
	   else translate($query-string, '{}', ' ') (:if there is an uneven number of braces, delete all braces.:)
    let $query-string :=
	   if ((functx:number-of-matches($query-string, '<') + functx:number-of-matches($query-string, '>')) mod 2 eq 0)
	   then $query-string
	   else translate($query-string, '<>', ' ') (:if there is an uneven number of angle brackets, delete all angle brackets.:)
    return $query-string
};

(: Function to translate a Lucene search string to an intermediate string mimicking the XML syntax,
with some additions for later parsing of boolean operators. The resulting intermediary XML search string will be parsed as XML with util:parse().
Based on Ron Van den Branden, https://rvdb.wordpress.com/2010/08/04/exist-lucene-to-xml-syntax/:)
(:TODO:
The following cases are not covered:
1)
<query><near slop="10"><first end="4">snake</first><term>fillet</term></near></query>
as opposed to
<query><near slop="10"><first end="4">fillet</first><term>snake</term></near></query>

w(..)+d, w[uiaeo]+d is not treated correctly as regex.
:)
declare %private function app:parse-lucene($string as xs:string) {
    (: replace all symbolic booleans with lexical counterparts :)
    if (matches($string, '[^\\](\|{2}|&amp;{2}|!) '))
    then
        let $rep :=
            replace(
            replace(
            replace(
                $string,
            '&amp;{2} ', 'AND '),
            '\|{2} ', 'OR '),
            '! ', 'NOT ')
        return app:parse-lucene($rep)
    else
        (: replace all booleans with '<AND/>|<OR/>|<NOT/>' :)
        if (matches($string, '[^<](AND|OR|NOT) '))
        then
            let $rep := replace($string, '(AND|OR|NOT) ', '<$1/>')
            return app:parse-lucene($rep)
        else
            (: replace all '+' modifiers in token-initial position with '<AND/>' :)
            if (matches($string, '(^|[^\w&quot;])\+[\w&quot;(]'))
            then
                let $rep := replace($string, '(^|[^\w&quot;])\+([\w&quot;(])', '$1<AND type=_+_/>$2')
                return app:parse-lucene($rep)
            else
                (: replace all '-' modifiers in token-initial position with '<NOT/>' :)
                if (matches($string, '(^|[^\w&quot;])-[\w&quot;(]'))
                then
                    let $rep := replace($string, '(^|[^\w&quot;])-([\w&quot;(])', '$1<NOT type=_-_/>$2')
                    return app:parse-lucene($rep)
                else
                    (: replace parentheses with '<bool></bool>' :)
                    (:NB: regex also uses parentheses!:)
                    if (matches($string, '(^|[\W-[\\]]|>)\(.*?[^\\]\)(\^(\d+))?(<|\W|$)'))
                    then
                        let $rep :=
                            (: add @boost attribute when string ends in ^\d :)
                            (:if (matches($string, '(^|\W|>)\(.*?\)(\^(\d+))(<|\W|$)'))
                            then replace($string, '(^|\W|>)\((.*?)\)(\^(\d+))(<|\W|$)', '$1<bool boost=_$4_>$2</bool>$5')
                            else:) replace($string, '(^|\W|>)\((.*?)\)(<|\W|$)', '$1<bool>$2</bool>$3')
                        return app:parse-lucene($rep)
                    else
                        (: replace quoted phrases with '<near slop="0"></bool>' :)
                        if (matches($string, '(^|\W|>)(&quot;).*?\2([~^]\d+)?(<|\W|$)'))
                        then
                            let $rep :=
                                (: add @boost attribute when phrase ends in ^\d :)
                                (:if (matches($string, '(^|\W|>)(&quot;).*?\2([\^]\d+)?(<|\W|$)'))
                                then replace($string, '(^|\W|>)(&quot;)(.*?)\2([~^](\d+))?(<|\W|$)', '$1<near boost=_$5_>$3</near>$6')
                                (\: add @slop attribute in other cases :\)
                                else:) replace($string, '(^|\W|>)(&quot;)(.*?)\2([~^](\d+))?(<|\W|$)', '$1<near slop=_$5_>$3</near>$6')
                            return app:parse-lucene($rep)
                        else (: wrap fuzzy search strings in '<fuzzy max-edits=""></fuzzy>' :)
                            if (matches($string, '[\w-[<>]]+?~[\d.]*'))
                            then
                                let $rep := replace($string, '([\w-[<>]]+?)~([\d.]*)', '<fuzzy max-edits=_$2_>$1</fuzzy>')
                                return app:parse-lucene($rep)
                            else (: wrap resulting string in '<query></query>' :)
                                concat('<query>', replace(normalize-space($string), '_', '"'), '</query>')
};

(: Function to transform the intermediary structures in the search query generated through app:parse-lucene() and util:parse()
to full-fledged boolean expressions employing XML query syntax.
Based on Ron Van den Branden, https://rvdb.wordpress.com/2010/08/04/exist-lucene-to-xml-syntax/:)
declare %private function app:lucene2xml($node as item(), $mode as xs:string) {
    typeswitch ($node)
        case element(query) return
            element { node-name($node)} {
            element bool {
            $node/node()/app:lucene2xml(., $mode)
        }
    }
    case element(AND) return ()
    case element(OR) return ()
    case element(NOT) return ()
    case element() return
        let $name :=
            if (($node/self::phrase | $node/self::near)[not(@slop > 0)])
            then 'phrase'
            else node-name($node)
        return
            element { $name } {
                $node/@*,
                    if (($node/following-sibling::*[1] | $node/preceding-sibling::*[1])[self::AND or self::OR or self::NOT or self::bool])
                    then
                        attribute occur {
                            if ($node/preceding-sibling::*[1][self::AND])
                            then 'must'
                            else
                                if ($node/preceding-sibling::*[1][self::NOT])
                                then 'not'
                                else
                                    if ($node[self::bool]and $node/following-sibling::*[1][self::AND])
                                    then 'must'
                                    else
                                        if ($node/following-sibling::*[1][self::AND or self::OR or self::NOT][not(@type)])
                                        then 'should' (:must?:)
                                        else 'should'
                        }
                    else ()
                    ,
                    $node/node()/app:lucene2xml(., $mode)
        }
    case text() return
        if ($node/parent::*[self::query or self::bool])
        then
            for $tok at $p in tokenize($node, '\s+')[normalize-space()]
            (:Here the query switches into regex mode based on whether or not characters used in regex expressions are present in $tok.:)
            (:It is not possible reliably to distinguish reliably between a wildcard search and a regex search, so switching into wildcard searches is ruled out here.:)
            (:One could also simply dispense with 'term' and use 'regex' instead - is there a speed penalty?:)
                let $el-name :=
                    if (matches($tok, '((^|[^\\])[.?*+()\[\]\\^|{}#@&amp;<>~]|\$$)') or $mode eq 'regex')
                    then 'regex'
                    else 'term'
                return
                    element { $el-name } {
                        attribute occur {
                        (:if the term follows AND:)
                        if ($p = 1 and $node/preceding-sibling::*[1][self::AND])
                        then 'must'
                        else
                            (:if the term follows NOT:)
                            if ($p = 1 and $node/preceding-sibling::*[1][self::NOT])
                            then 'not'
                            else (:if the term is preceded by AND:)
                                if ($p = 1 and $node/following-sibling::*[1][self::AND][not(@type)])
                                then 'must'
                                    (:if the term follows OR and is preceded by OR or NOT, or if it is standing on its own:)
                                else 'should'
                    }
                    (:,
                    if (matches($tok, '((^|[^\\])[.?*+()\[\]\\^|{}#@&amp;<>~]|\$$)'))
                    then
                        (\:regex searches have to be lower-cased:\)
                        attribute boost {
                            lower-case(replace($tok, '(.*?)(\^(\d+))(\W|$)', '$3'))
                        }
                    else ():)
        ,
        (:regex searches have to be lower-cased:)
        lower-case(normalize-space(replace($tok, '(.*?)(\^(\d+))(\W|$)', '$1')))
        }
        else normalize-space($node)
    default return
        $node
};


   declare function app:biblform($node as node(), $model as map(*)){
   <form xmlns="http://www.w3.org/1999/xhtml"  action="" class="w3-container">

      <div  class="w3-container">
                               <small class="form-text text-muted">enter a Zotero bm:id</small>
                                <input class="w3-input w3-border" name="pointer" placeholder="bm:"></input>
                                </div>
                                <div class="w3-container w3-bar">
                                 <button type="submit" class="w3-button w3-pale-green w3-bar-item">
                                 <i class="fa fa-filter" aria-hidden="true"></i></button>
                                 <a href="/Dillmann/bibl.html" role="button" class="w3-button w3-pale-green w3-bar-item"><i class="fa fa-th-list" aria-hidden="true"></i></a></div>
   </form>
   };

(:~prints a responsive table with the first 100 ptr targets fount in
 : all the bibliography entries in the  entities in the app taken once, requesting the data from Zotero:)
declare

    %templates:default("collection", "")
    %templates:default("pointer", "")
function app:bibl ($node as node(), $model as map(*),
     $collection as xs:string, $pointer as xs:string*) {
   let $coll := ' $config:collection-root'
   let $Pointer := if($pointer = '') then () else "[.='"||$pointer||"']"
   let $path := $coll||'//tei:ptr/@target'||$Pointer
   let $query := util:eval($path)
let $bms :=
for $bibl in distinct-values($query)
return
$bibl
    return
   map {
                    "hits" := $bms,
                    "total" := count($bms),
                    "type" := 'bibliography'

                }

     };

     declare
%templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 10)
    function app:biblRes($node as node(), $model as map(*), $start as xs:integer, $per-page as xs:integer){

for $target at $p in subsequence($model("hits"), $start, $per-page)
let $ptrs :=  $config:collection-root//tei:ptr[@target = $target]
let $count := count($ptrs)
order by $count descending
return
<div class="w3-container w3-margin biblio">
    <div id="{$target}" class="biblioentry w3-half"/>
<div class="w3-half">
<div class="w3-threequarter biblioRes">
<ul>
    {
   for $citingentity in $ptrs/@target
   group by $root :=    $citingentity/ancestor::tei:entry
   let $lem := root($root)//tei:entry/tei:form/tei:foreign[1]/text()
   order by $lem
    return
    <li><a href="/Dillmann/lemma/{string($root/@xml:id)}">{$lem}</a></li>
    }
    </ul>
    </div>
    <div class="w3-quarter">{$count}</div>
    </div>
    </div>
};


declare function app:guidelines($node as node()*, $model as map(*)){
doc('/db/apps/gez-en/guidelines.xml')
        };


declare function app:footer($node as element(), $model as map(*)){
 doc('/db/apps/gez-en/footer.xml')
        };

  declare function app:NavB($node as element(), $model as map(*)){
    <div class="w3-top">
        <div class="w3-bar w3-black w3-card">
            <a class="w3-bar-item w3-button  w3-hide-medium w3-hide-large w3-right" href="javascript:void(0)"
                onclick="myFunction()" title="Toggle Navigation Menu"><i class="fa fa-bars"></i></a>

            <div class="w3-bar-item w3-hide-small" id="brand">
                    <a href="/Dillmann/">{$config:expath-descriptor/expath:title/text()}</a>

        </div>
        {  if(sm:id()//sm:username/text() = 'guest') then

          <div class="w3-dropdown-hover w3-hide-small" id="logging">
               <button class="w3-button  w3-bar-item">Login <i class="fa fa-caret-down"></i></button>
               <div class="w3-dropdown-content w3-bar-block w3-card-4">

           <form method="post" class="w3-container" role="form"
           accept-charset="UTF-8" id="login-nav">
                             <label for="user">User:</label>
                                     <input type="text" name="user" required="required" class="w3-input"/>

                                 <label for="password">Password:</label>
                                     <input type="password" name="password" class="w3-input"/>

                                     <button class="w3-button w3-small w3-bar-item w3-red" type="submit">Login</button>

                         </form>
                         </div>
                         </div>
                         else
                       <form method="post" action="" class="w3-bar-item w3-hide-smal" style="margin:0;padding:0" role="form" accept-charset="UTF-8" id="logout-nav">

                       <button  class=" w3-button w3-red w3-bar-item" type="submit">Logout</button>

                       <input value="true" name="logout"  type="hidden"/>

                       </form>
}
            <div class="w3-dropdown-hover w3-hide-small" id="about">
                  <a 
                  class=" w3-button" title="about" 
                  href="/Dillmann/user/{xmldb:get-current-user()}"  
                  target="_blank">
Hi {xmldb:get-current-user()}!<i class="fa fa-caret-down"></i></a>
            <div class="w3-dropdown-content w3-bar-block w3-card-4">
              <a class="w3-bar-item w3-button" href="/Dillmann/about.html">About this app</a>
              <a class="w3-bar-item w3-button" href="/Dillmann/DillmannProlegomena.html">Dillmann Prolegomena</a>

            </div>
          </div>
          <div class="w3-dropdown-hover w3-hide-small" id="lists">
      <button class=" w3-button" title="Resources">Resources <i class="fa fa-caret-down"></i></button>     
      <div class="w3-dropdown-content w3-bar-block w3-card-4">
          <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium"  id="list" href="/Dillmann/list">Browse</a>
          <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" id="biblio" href="/Dillmann/bibl.html">Bibliography</a>
          <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" href="/Dillmann/reverse" id="reverse">Reverse Index</a>
         <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" href="/Dillmann/abbreviations" id="abbreviations">Abbreviations</a>
             <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" href="/Dillmann/citations" id="quotes">Citations</a>
         <div class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" id="downloads" data-template="app:downloadbutton"/>
         </div>
         </div>
          <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" id="getInvolved" href="/Dillmann/getinvolved.html">Get involved</a>
          <div class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" id="tutorial" data-template="app:tutorial"/>
        <div class="w3-bar-item w3-button  w3-hide-small w3-hide-medium" id="BM" data-template="app:bmbutton"/>

         <a class="w3-bar-item w3-button  w3-hide-small w3-hide-medium"
          href="https://github.com/BetaMasaheft/Dillmann/issues/new?title=something%20is%20very%20wrong&amp;assignee=PietroLiuzzo">
             <i class="fa fa-exclamation-circle" aria-hidden="true"/> report issue</a>
               <a href="/Dillmann"  class="w3-padding w3-hover-red w3-hide-small w3-right"><i class="fa fa-search"></i></a>
    </div>
    </div>};

 declare function app:modals($node as element(), $model as map(*)){
   <div id="versionInfo" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">close</button>
                        <h4 class="modal-title">This is a testing and dev website!</h4>
                    </div>
                    <div class="modal-body">
                        <p>        You are looking at a pre-alpha version of this website. If you are not an editor you should not even be seeing it at all. For questions <a  target="_blank" href="mailto:pietro.liuzzo@uni-hamburg.de?Subject=Issue%20Report%20BetaMasaheft">contact the dev team</a>.</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        };

         declare function app:searchhelp($node as element(), $model as map(*)){
          doc('../searchhelp.xml')
        };
