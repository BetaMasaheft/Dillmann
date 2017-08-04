xquery version "3.0";

module namespace app="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mail="http://exist-db.org/xquery/mail";
declare namespace functx = "http://www.functx.com";
declare namespace expath="http://expath.org/ns/pkg";

import module namespace kwic = "http://exist-db.org/xquery/kwic"    at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace validation = "http://exist-db.org/xquery/validation";
 
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
 
 
(:the forms in the advanced search. this are called by a ajax call requesting as.html as a part of the html output. 
Jquery cares also about the loading it once only and then simply hiding or showing it. :)
 declare function app:forms($node as element(), $model as map(*)){
 let $data-collection := '/db/apps/gez-en/data'
    let $collection := collection($data-collection)
   
return (
<div class="col-md-12">
<div class="form-group erweit  col-md-4">
                        <small class="form-text text-muted">Search for entries which (don't) contain corresponding words in </small>
                        <div  id="languages">
                        <label class="switch">
                            <input type="checkbox" name="notlang"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            <input type="checkbox" name="languages" value="ar"/>Arabic<br/>
                            <input type="checkbox" name="languages" value="grc"/>Greek<br/>
                            <input type="checkbox" name="languages" value="cop"/>Coptic<br/>
                            <input type="checkbox" name="languages" value="la"/>Latin<br/>
                            <input type="checkbox" name="languages" value="syr"/>Syriac<br/>
                            <input type="checkbox" name="languages" value="he"/>Hebrew<br/>
                        </div>
                </div>
                <div class="form-group erweit  col-md-4">
                        <small class="form-text text-muted">Search for entries which (don't) contain this case </small>
                        <div id="case">
                            <label class="switch">
                            <input type="checkbox" name="notcase"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            
                            <input type="checkbox" name="case" value="accusativus"/>accusativus<br/>
                            <input type="checkbox" name="case" value="dativus"/>dativus<br/>
                        </div>
                </div>
                <div class="form-group erweit col-md-4">
                        <small class="form-text text-muted">Search for entries which (don't) contain this gender </small>
                        <div id="gender">
                            <label class="switch">
                            <input type="checkbox" name="notgen"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/> 
                            <input type="checkbox" name="case" value="f"/>femininus<br/>
                            <input type="checkbox" name="case" value="m"/>masculinus<br/>
                        </div>
                </div>
                </div>,
                <div class="col-md-12">
                <div class="form-group erweit col-md-6">
<small class="form-text text-muted">Search for entries which (don't) contain this PoS </small>
                        <div id="PoS">
                            <label class="switch">
                            <input type="checkbox" name="notpos"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                            {for $x in distinct-values($collection//tei:pos/@expand) return (<input type="checkbox" name="pos" value="{$x}"/>, $x, <br/>)}

                        </div>
                </div>

<div class="form-group erweit  col-md-6">
                        <small class="form-text text-muted">Search for entries which (don't) contain this label </small>
                        <div id="lbl">
                            <label class="switch">
                            <input type="checkbox" name="notlbl"/>
                            <div class="slider round" data-toggle="tooltip" title="not"></div>
                            </label><br/>
                           { for $x in distinct-values($collection//tei:lbl/@expand) return (<input type="checkbox" name="lbl" value="{$x}"/>, $x, <br/>)}

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
    let $data-collection := '/db/apps/gez-en/data'
    let $collection := collection($data-collection)
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
     
     <div class="col-md-12">
     <div class="col-md-2">
     <ul class="nav nav-pills nav-stacked">
     <li><a role="button" class="btn btn-info" href="?start=1&amp;mode=cit">list translations (defualt)</a></li>
     <li><a role="button" class="btn btn-info" href="?start=1&amp;mode=foreign">non latin terms</a></li>
     </ul>
     <ul class="nav nav-pills nav-stacked">
     {for $lang in distinct-values($langs)
        return
        if ($lang = 'gez') then () else
                <li><a role="button" class="btn  btn-primary" href="?start=1&amp;lang={$lang}{$mpar}">{$lang}</a></li>}
      </ul>
     <ul class="nav nav-pills nav-stacked">{for $hit in $data
         let $first := substring($hit('hit'), 1, 1)
            group by $f := $first
            return 
                <li><a role="button" class="btn btn-success" href="?start=1&amp;letter={$f}{$mpar}{$lpar}">{$f} <span class="badge">{count($hit)}</span></a></li>}
                <li><a role="button" class="btn btn-info" href="?start=1{$mpar}{$lpar}">back to full list</a></li>
      </ul>
          
      </div>
          <div class="col-md-10">  { if (count($data) lt 1) then (<p class="lead">Please select a value on the side bar.</p>) else 
 for $hit in subsequence($data, $start, $per-page)
 return
 <div class="row">
     <div class="col-md-4">{$hit('hit')}</div>
     <div  class="col-md-8">
     <ul class="nodot">
     {for $r in $hit('roots')
     let $collection := collection($config:data-root)
     let $entry := $collection//id($r)
     let $term-name := let $terms := $entry//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms
              
         return
             <li class="nodot"><a target="blank" href="/Dillmann/lemma/{$r}">{$term-name}</a></li>
     }
        </ul> 
     </div>
 </div>}
 </div>
 </div>
 };
 
 
(: as per requirement it is possible to transform the entire data in a huge txt file. this is stored in the app and then made available for download. the request takes some time...:)
 declare function app:download($node as element(), $model as map(*)){
   let $data-collection := '/db/apps/gez-en/data/'
   let $txtarchive := '/db/apps/gez-en/txt/'
   (: store the filename :)
   let $filename := concat('Dillmann_Lexicon_', format-dateTime(current-dateTime(), "[Y,4][M,2][D,2][H01][m01][s01]"), '.txt')
   let $filecontent := for $d in collection($data-collection) 
               order by $d//tei:entry/@n
                return
                                      transform:transform($d, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())
 let $Text := string-join($filecontent, ' &#13;')
    (: create the new file with a still-empty id element :)
    let $store := xmldb:store($txtarchive, $filename, $Text)
return
 <a
    id="downloaded"
    href="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/txt/{$filename}"
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
 if(xmldb:get-current-user() = 'guest') then
 <li class="dropdown">
          <a href="#" 
          class="dropdown-toggle" 
          data-toggle="dropdown"><b>Login</b> 
          <span class="caret"></span></a>
			<ul id="login-dp" class="dropdown-menu">
				<li>
		 <div class="row">
			<div class="col-md-12">
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
 (: goes with login button, had to put it here to comment it out...
	<a class="btn btn-primary"  href="/Dillmann/createaccount.html">Create a new account</a>
		:)
                else
              <li  class="dropdown"> 
              <form method="post" action="" class="navbar-form" role="form" accept-charset="UTF-8" id="logout-nav">
               <input value="true" name="logout" class="form-control" type="hidden"/>
                        
              <button  class="btn btn-primary btn-xs" type="submit">Logout</button>
              </form>
              </li>
}; 

(:on login, print the name of the logged user:)
declare function app:greetings($node as element(), $model as map(*)) as xs:string{
<a href="">Hi {xmldb:get-current-user()}!</a>
    };
    
(:the button to the pdf of a file. the request ending with .pdf triggers in the controller a xslt transformation    :)
 declare function app:pdf-link($id) {
    
        <a role="button" class="btn btn-info" xmlns="http://www.w3.org/1999/xhtml" href="{$id}.pdf">{'pdf'}</a>
};

(:the button which allows to download the source xml file:)
 declare function app:getXML($id){
 <a
    href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/lemma/{$id}.xml"
    download="{$id}.xml"
    class="btn btn-primary"><i
        class="fa fa-download"
        aria-hidden="true"></i>TEI/XML</a>
 };
 
 
(:    the button linking the the new entry form, an html page with a form posting data to a xql which will store a file and notify the editors:)
   declare function app:newentry($node as element(), $model as map(*)) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a role="button" class="btn btn-info" href="/Dillmann/newentry.html">
                   New Entry
                </a>)
else ()
};  

(:the link to the download page, only available for lexicon group:)
   declare function app:downloadbutton($node as element(), $model as map(*)) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a href="/Dillmann/downloads.html">Downloads</a>
)
else ()
};  

(:form to navigate Dillmann using the column numbers :)
 declare function app:gotocolumn($node as element(), $model as map(*)) {
  <form action="" class="form form-horizontal" id="GtC">
  <div class="form-group">
 <div class="input-group">

  <span class="input-group-addon" id="basic-addon3">column number</span>
  <input type="number" class="form-control" id="columnnumber" aria-describedby="basic-addon3" name="GtC"/>
  <span class="input-group-btn">
        <button class="btn btn-secondary" type="submit">Go!</button>
      </span>
</div>
</div>
</form>
};  

(:the button to delete an entry, only available for lexicon group:)

  declare function app:deleteEntry($id) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
<a role="button" class="btn btn-danger delete" href="/Dillmann/edit/delete-confirm.xq?id={$id}">
                   <i class="fa fa-trash" aria-hidden="true"></i>
                </a>)
else ()
};  

(:the button to edit an entry, only available for lexicon group. the name of the function is old, it does not go anymore to exide but to the update form:)

declare function app:editineXide($id as xs:string, $sources as node()) {
if(contains(sm:get-user-groups(xmldb:get-current-user()), 'lexicon')) then (
let $ss := for $source in $sources/source return '&amp;source' || $source/@lang ||'=' ||substring-after($source/@value, '#')
let $sourcesparam := string-join($ss, '')
return
    <a role="button" class="btn btn-primary" href="/Dillmann/update.html?id={$id}&amp;new=false{$sourcesparam}">Update</a>
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
            <div class="col-md-2"><h3><a href="lemma/{$id}">{$hit/tei:form}</a></h3>{app:editineXide($bURI, <sources>{for $s in $hit/tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>
<div class="col-md-5">{transform:transform($hit/tei:sense[@xml:lang='la'], 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl', (<parameters><param name="refText" value="no"/></parameters>))}</div>
<div class="col-md-5">{transform:transform($hit/tei:sense[@xml:lang='en'], 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl', ())}</div>
        </div>
};:)

(:storing separately this input in this function makes sure that when the page is reloaded with the results the value entered remains in the input element:)
declare function app:queryinput ($node as node(), $model as map(*), $q as xs:string*){<input name="q" type="search" class="form-control diacritics" placeholder="Search string" value="{$q}"/>};


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
{ let $c := collection('/db/apps/gez-en/data')
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
<th>Dillmann's Explanation</th>
<th>Normalization</th>
<th>BM Work ID</th>
</tr>
</thead>
<tbody>
{let $refs := for $r2 in collection('/db/apps/gez-en/data')//tei:ref[@cRef]
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
let $c := collection('/db/apps/gez-en/data')
let $abbreviaturen := doc('../abbreviaturen.xml')
return
<div id="citationsList" class="col-md-12">
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
                        case "SH" return 'Sususanne Hummel'
                        case "FP" return 'Francesca Panini'
                        case "DE" return 'Daria Elagina'
                        case "MK" return 'Magdalena Krzyżanowska'
                        case "VR" return 'Veronika Roth'
                        case "AA" return 'Abreham Adugna'
                        case "EG" return 'Ekaterina Gusarova'
                        case "IR" return 'Irene Roticiani'
                        case "MB" return 'Maria Bulakh'
                        case "WD" return 'Wolfgang Dickhut'
                        default return 'Alessandro Bausi'};

(:prints the information in revisionDesc:)
declare function app:revisions($term){
       <div class="collapse card-block" id="revisions">
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

(:print the entry, transforming with xsl the contents and preparing the html for further dispaly rework done in videas.js :)
declare function app:item($node as node(), $model as map(*)){
let $col := collection('/db/apps/gez-en/data')
let $id := request:get-parameter("id", "")
let $term := $col//id($id)
let $n := data($term/@n)
let $column := if($term//tei:cb) then string(($term//tei:cb/@n)[1]) else string(max($col//tei:cb[xs:integer(ancestor::tei:entry/@n) <= xs:integer($n)][@xml:id]/@n))
let $hom := if($term//tei:form/tei:seg[@type='hom']) then concat($term//tei:form/tei:seg[@type='hom']/text(), ' ') else ()
let $rootline := if($term//tei:form/tei:rs[@type='root']) then (<button class="btn btn-xs btn-info" id="rootmembers" data-value="{$id}"><span class="lead">Root</span></button>) else (<button class="btn btn-xs btn-info" id="rootmembers"  data-value="{$id}">Root</button>)
let $ne := xs:integer($n) + 1
let $pr := xs:integer($n) - 1
let $NE := string($ne)
let $PR := string($pr)
let $next := string($col//tei:entry[@n = $NE]/@xml:id)
let $prev := string($col//tei:entry[@n = $PR]/@xml:id)


return
<div class="col-md-12">
        <h1>{$hom}<span id="lemma">{let $terms := root($term)//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms}</span><div class=" btn-group downloadlinks">{app:pdf-link($id)}{app:getXML($id)}</div>{app:deleteEntry($id)}
         {$rootline}
         {if($term//tei:nd) then (<a href="#" class="btn btn-success">New</a>) else(<span class="badge columns"><a target="_blank" href="{concat('http://www.tau.ac.il/~hacohen/Lexicon/pp', format-number(if(xs:integer($column) mod 2 = 1) then  if($term//tei:cb) then (xs:integer($column)  -2) else $column else (xs:integer($column)  -1), '#'), '.html')}"><i class="fa fa-columns" aria-hidden="true"/> {' ' || format-number($column, '#')}</a></span>)}</h1>
        <a  class="smallArrow" href="/Dillmann/lemma/{$prev}">
        <i class="fa fa-chevron-left" aria-hidden="true"></i>
        
{$col//id($prev)//tei:form/tei:foreign/text()}</a> {' | '} <a  class="smallArrow next" data-value="{$next}" href="/Dillmann/lemma/{$next}">{$col//id($next)//tei:form/tei:foreign/text()} 
 
 <i class="fa fa-chevron-right" aria-hidden="true"></i>
 </a>
 <div id="showroot"/>
 {for $sense in $term//tei:sense[not(@rend)][not(@n)]
return  <div class="card-block"> <h3>{
switch($sense/@xml:lang) case 'la' return 'Latin' case 'ru' return 'Russian' case 'en' return 'English' case 'de' return 'Deutsch' 
case 'it' return 'Italian' default return $sense/@xml:id} 
{if($sense/@source) then (let $s := substring-after($sense/@source, '#') return <a href="#" data-toggle="tooltip" title="{root($term)//tei:sourceDesc//tei:ref[@xml:id=$s]//text()}"><i class="fa fa-info-circle" aria-hidden="true"></i></a>) else ()}

</h3>
{transform:transform($sense, 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl',())}</div>}
     
      <div class="btn-group">
      <button type="button" class="btn btn-info" data-toggle="collapse" data-target="#revisions">Revisions</button>
      {app:editineXide($id, <sources>{for $s in $term//tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}
   <a role="button" class="btn btn-info" target="_blank" href="mailto:pietro.liuzzo@uni-hamburg.de?Subject=[Dillmann]%20{$id}">
   <i class="fa fa-envelope-o" aria-hidden="true"></i>
</a></div>
   {app:revisions($term)}
    </div>
};


(:print the entry in the main landing page, transforming with xsl the contents and preparing the html for further dispaly rework done in videash.js 
the difference from the previous function is in that here parameters need to be taken into account. It has also a switch, which is not in the main view, which higlights the terms from teh search
:)
declare function app:showitem($node as node()*, $model as map(*), $id as xs:string?){
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
let $col := collection('/db/apps/gez-en/data')
let $id := request:get-parameter('id', ())
let $term := $col//id($id)
let $hom := if($term//tei:form/tei:seg[@type='hom']) then concat($term//tei:form/tei:seg[@type='hom']/text(), ' ') else ()
let $rootline := if($term//tei:form/tei:rs[@type='root']) then (<button class="btn btn-xs btn-info" id="rootmembers" data-value="{$id}"><span class="lead">Root</span></button>) else (<button class="btn btn-xs btn-info" id="rootmembers"  data-value="{$id}">Root</button>)
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
if ($id) then (
<div class="well container-fluid">


        <h1>{$hom}<span id="lemma"><a target="_blank" href="/Dillmann/lemma/{$id}">{let $terms := root($term)//tei:form/tei:foreign/text() return if (count($terms) gt 1) then string-join($terms, ' et ') else $terms}</a></span>
        {$rootline}
        {if($term//tei:nd) then (<a href="#" class="btn btn-success">New</a>) else(<span class="badge columns"><a target="_blank" href="{concat('http://www.tau.ac.il/~hacohen/Lexicon/pp', format-number(if(xs:integer($column) mod 2 = 1) then  if($term//tei:cb) then (xs:integer($column)  -2) else $column else (xs:integer($column)  -1), '#'), '.html')}">
        <i class="fa fa-columns" aria-hidden="true"/> {if($term//tei:cb) then (string(number(format-number($column, '#')) - 1) || '/' || format-number($column, '#')) else (' ' || format-number($column, '#'))}</a></span>)}
        <label class="switch highlights">
  <input type="checkbox"/>
  <div class="slider round" data-toggle="tooltip" title="Show or Hide highlights of each element in the entry (lemma excluded!) containing your query as a string. 
  This might be different from the hits on the left, but it should help you to find your match faster."></div>
</label>
<div class=" btn-group downloadlinks">{app:pdf-link($id)}{app:getXML($id)}</div>{app:deleteEntry($id)}
        
</h1>
        <a class="smallArrow" href="?{$params}&amp;id={$prev}">
        <i class="fa fa-chevron-left" aria-hidden="true"></i>
        
{$col//id($prev)//tei:form/tei:foreign/text()}</a>{ ' | '}  
<a  class="smallArrow next" data-value="{$next}" href="?{$params}&amp;id={$next}">{$col//id($next)//tei:form/tei:foreign/text()} 
 
 <i class="fa fa-chevron-right" aria-hidden="true"></i>
 </a>
 <div id="showroot"/>
 {for $sense in $term//tei:sense[not(@n)]
return  <div class="card-block entry"> 
<h3>{switch($sense/@xml:lang) 
case 'la' return 'Latin' 
case 'en' return 'English' 
case 'de' return 'Deutsch' 
case 'it' return 'Italian' 
default return $sense/@xml:id}
{if($sense/@source) then (let $s := substring-after($sense/@source, '#') return <a href="#" data-toggle="tooltip" title="{root($term)//tei:sourceDesc//tei:ref[@target=$s]//text()}"><i class="fa fa-info-circle" aria-hidden="true"></i>
</a>) else ()}
</h3>

{transform:transform($sense, 'xmldb:exist:///db/apps/gez-en/xslt/text.xsl',())}
</div>}
     
       
      <div class="btn-group">
      <button type="button" class="btn btn-info" data-toggle="collapse" data-target="#revisions">Revisions</button>
      {app:editineXide($id, <sources>{for $s in $term/tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}
   <a role="button" class="btn btn-info" target="_blank" href="mailto:pietro.liuzzo@uni-hamburg.de?Subject=[Dillmann]%20{$id}">
   <i class="fa fa-envelope-o" aria-hidden="true"></i>
</a></div>
{app:revisions($term)}

    
<div>
 
    </div>    

    </div>,
    <div class="alert alert-info">
        <h3><span id='NumOfAtt'/>Attestations in the Beta maṣāḥǝft corpus</h3>
    <div id="attestations" />
    </div>
)
else (<div class="well">Search and click on a search result to see it here. You will be able to click on words, browse the previous and next entries, get the result on its own page and see related finds from Beta maṣāḥǝft.</div>)};



declare  %templates:wrap function app:editedItem($node as node()*, $model as map(*)){
let $new := request:get-parameter('new', '')
let $id := request:get-parameter('id', '')
let $data-collection := '/db/apps/gez-en/data/'

let $file := if ($new='true') then 
        'new-instance.xml'
    else 
        collection($data-collection)//id($id)
return map {'file' := $file,
'id' := $id}
};

declare function app:newForm ($node as node()*, $model as map(*)){
 <form id="createnew" action="/Dillmann/edit/save-new-entity.xql" method="post">
             <div class="form-group">
            <label for="form" class="col-md-2 col-form-label">Lemma</label>
            <div class="col-md-10">
                <input class="form-control" id="form" name="form" required="required" value="{if(request:get-parameter('form',())) then request:get-parameter('form',()) else ()}"/>
                <small class="form-text text-muted">type here the new Gǝʿǝz form to be added</small>
            </div>
        </div>
        <div class="form-group">
            <label for="source" class="col-md-2 col-form-label">Source</label>
            <div class="col-md-10">
                <select class="form-control" id="sourceen" name="sourceen" required="required">
                <option value="dillmann">Dillmann</option>
                <option value="traces">TraCES</option>
                </select>
                <small class="form-text text-muted">type here the new Gǝʿǝz form to be added</small>
            </div>
        </div>
       
        <div class="form-group">
            <label for="senseen" class="col-md-2 col-form-label">Sense</label>
            <div class="col-md-10">
            {app:buttons('en')}
                <textarea class="form-control" id="senseen" 
                name="senseen"  style="height:250px;">{if(request:get-parameter('senseen',())) then request:get-parameter('senseen',()) else ('<Sen<   {ND} >S>')}</textarea>
                <small class="form-text text-muted">type here your definition, following the guidelines below.</small>
            </div>
        </div>
        <div id="addsense"></div>
        <button class="btn btn-success add_field_button">Add More Meanings</button>
        
        <div class="form-group">
       
            <label for="msg" class="col-md-2 col-form-label" >What have you done?</label>
            <div class="col-md-10">
                <textarea class="form-control" id="msg" name="msg" required="required">{if(request:get-parameter('msg',())) then request:get-parameter('msg',()) else ()}</textarea>
                <small class="form-text text-muted">shortly describe why you created this entry</small>
            </div>
        </div>
        <button id="confirmcreatenew" type="submit" class="btn btn-primary" disabled="disabled">create new entry</button>
    </form>
};

declare function app:updateFormGroup($sense){
let $lang := string($sense/@xml:lang)
let $paramname := 'sense' || $lang
let $existingsource := 'source' || $lang
let $parexistingsource := request:get-parameter($existingsource, ())
let $source := if($sense/@source) then string($sense/@source) else ' (' || app:switchLangName($sense) || ')'
return
<div><div class="form-group">
            <label for="source{$lang}" class="col-md-2 col-form-label">Source of {'Sense' || $source}</label>
            <div class="col-md-10">
                <select class="form-control" id="source{$lang}" name="source{$lang}" required="required">
                <option value="dillmann">
                {if($parexistingsource = 'dillmann') then(attribute selected{'selected'}) else ()}
                Dillmann
                </option>
                <option value="traces">
                {if($parexistingsource = 'traces') then(attribute selected{'selected'}) else ()}
                TraCES
                </option>
                </select>
                <small class="form-text text-muted">type here the new Gǝʿǝz form to be added</small>
            </div>
        </div>
 <div class="form-group">
            
            <label for="sense{$lang}" class="col-md-2 col-form-label">{'Sense' || $source}</label>
            <div class="col-md-10">
            {app:buttons($lang)}
            <div id="wrap">
			
                <textarea class="form-control" id="sense{$lang}" name="sense{$lang}" style="height:250px;">{if(request:get-parameter($paramname,())) then request:get-parameter($paramname,()) else transform:transform($sense, 'xmldb:exist:///db/apps/gez-en/xslt/xml2editor.xsl', ())}</textarea>
             </div>
             <small class="form-text text-muted">type here your latin definition</small>
            </div>
        </div>
        <a href="#" class="btn btn-danger remove_field btn-xs">Remove {$lang} meaning permanently</a></div>
        
};

declare function app:update ($node as node()*, $model as map(*)) {

let $id := $model('id')
let $file := $model('file')
(:this will match tei:entry:)

return

               ( <h2>Edit Entry</h2>,
           <p class="lead">Hi {xmldb:get-current-user()}! You are updating {$file//tei:form/tei:foreign/text()}, that's great!</p>,
           <p class="lead"> Please follow the guidelines below for editing the entries.</p>,
           <p> Remember, you are here editing the dictionaries as sources of information, not annotating texts. The structure given to the entries is usefull for many purposes.</p>,
                <form id="updateEntry" action="/Dillmann/edit/edit.xq" class="input_fields_wrap" method="post">
                <input hidden="hidden" value="{$id}" name="id"/>
                   <div class="form-group">
            <label for="form" class="col-md-2 col-form-label">Lemma</label>
            <div class="col-md-10">
            <div class="input-group">
            <span class="input-group-addon">
            <input type="checkbox" id="rootCheck" name="root" value="root">
                {if($file//tei:form/tei:rs[@type]) then attribute checked {'checked'} else ()}
                </input>
            </span>
                <input class="form-control" id="senselemma" name="form" value="{$file//tei:form/tei:foreign/text()}"/>
              <span class="input-group-btn"> <a class="iconlemma btn btn-success">
                                <i class="fa fa-keyboard-o" aria-hidden="true"></i>
                                </a>
          </span>
              <small class="form-text text-muted">you can correct here the Gǝʿǝz form. Simply type it.</small>
            </div>
            </div>
        </div>
        
            
              
        {for $sense in $file//tei:sense[@xml:lang][@n='S' or not(@n)]
        return app:updateFormGroup($sense)}
        <div id="addsense"></div>
        <button class="btn btn-success add_field_button">Add More Meanings</button>
        
        <div class="form-group">
       
            <label for="msg" class="col-md-2 col-form-label" >What have you done?</label>
            <div class="col-md-10">
                <textarea class="form-control" id="msg" name="msg" required="required">{if(request:get-parameter('msg',())) then request:get-parameter('msg',()) else ()}</textarea>
                <small class="form-text text-muted">shortly describe the changes you have made</small>
            </div>
        </div>
        <button id="confirmcreatenew" type="submit" class="btn btn-primary">Confirm (or loose all your changes)</button>
                </form>
                
                )
      
};

declare function app:buttons($name){
<div class="btn-group"><a id="{$name}NestSense" class="btn btn-primary btn-sm">Meaning</a>
            <a id="{$name}translation" class="btn btn-primary btn-sm">Translation</a>
            <a id="{$name}transcription" class="btn btn-primary btn-sm">Transcription</a>
            <a id="{$name}PoS" class="btn btn-primary btn-sm">PoS</a>
            <a id="{$name}reference" class="btn btn-primary btn-sm">Reference</a>
            <a id="{$name}bibliography" class="btn btn-primary btn-sm">Bibliography</a>
            <a id="{$name}otherLanguage" class="btn btn-primary btn-sm">Language</a> 
            <a id="{$name}internalReference" class="btn btn-primary btn-sm">Internal Reference</a>
            <a id="{$name}gramGroup" class="btn btn-primary btn-sm">Grammar Group</a>
            <a id="{$name}label" class="btn btn-primary btn-sm">Label</a>
            <a id="{$name}case" class="btn btn-primary btn-sm">Case</a>
            <a id="{$name}gen" class="btn btn-primary btn-sm">Gender</a>
            <a id="{$name}ND" class="btn btn-primary btn-sm">ND</a>
            <a href="#" id="icon{$name}" class="btn btn-primary btn-sm"> <i class="fa fa-keyboard-o" aria-hidden="true"></i></a>
         </div>
};
declare function app:upconvertSense($senseAndSource) as node(){

let $newTextsource := $senseAndSource/source
let $newText := $senseAndSource/sense
let $newsense := transform:transform(<node>{$newText}</node>, 'xmldb:exist:///db/apps/gez-en/xslt/upconversion.xsl', <parameters>
    <param name="source" value="{$newTextsource}"/>
</parameters>)
return 
($newsense, console:log($newsense))
};

declare function app:DoUpdate($node as node()*, $model as map(*)){
let $parametersName := request:get-parameter-names()
let $cU := xmldb:get-current-user()
let $file := $model('file')
let $id := $model('id')
let $msg := request:get-parameter('msg', ())
let $title := 'Update Confirmation'
let $data-collection := '/db/apps/gez-en/data'
let $record := collection($data-collection)//id($id)
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
                  <p>{$cU} said he: {$msg} in this file</p>
                  <p>This is how it looks like in txt now:</p>
                  <p>{transform:transform($rootitem, 'xmldb:exist:///db/apps/gez-en/xslt/txt.xsl', ())}</p>
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
<div class="alert alert-success">
    <h2>{$title}</h2>
    <p class="lead">Dear {$cU}, Lemma  <a href="/Dillmann/lemma/{$id}">{$filename}</a> has been updated successfully!</p>
   <p>A notification email has been sent to the editors.</p>
   <p class="lead">Thank you!</p>
  </div>
  )
  else (
  <div class="col-md-12 alert alert-warning">
  
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




declare function app:subs($query, $homophones, $mode) {
    let $all :=
    for $b in $homophones
    return
    for $q in $query return
        if (contains($q, $b)) then
            let $options := for $s in $homophones[. != $b]
            return
                (replace($q, $b, $s),
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
                let $lpvals:= for $slp in $lp return "@" ||$attName || "='"|| $slp || "'"
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
let $data-collection := '/db/apps/gez-en/data'
let $coll := collection($data-collection)
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
let $test := console:log($query)
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

let $erw := $l || $c || $p || $lbl || $g 

let $data-collection := '/db/apps/gez-en/data'
let $coll := collection($data-collection)
return

if(empty($q)) then (
if($cun) then (
let $formatCun := format-number($cun, '0000')
let $test1 := console:log($formatCun)
let $hits := for $hit in $coll//tei:entry//tei:cb[@n=$formatCun] return $hit

 let $test2 :=console:log($hits)
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
let $test := console:log($qtext)
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
  map {"hits" := $hits}
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

(:~
 : FROM SHAKESPEAR
    Create a span with the number of items in the current search result.
:)
declare 
    %templates:wrap function app:hit-count($node as node()*, $model as map(*)) {
    let $q := request:get-parameter('q',())
    return
    if(empty($q)) then () else 
    <h3>You found "{$q}" in <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ count($model("hits")) }</span> entries!</h3>
    
};


declare %private function app:create-query($query-string as xs:string?, $mode as xs:string) {
    let $test := console:log($query-string)
    let $query-string := 
        if ($query-string) 
        then app:sanitize-lucene-query($query-string) 
        else ''
        let $test2 := console:log($query-string)
    let $query-string := normalize-space($query-string)
    let $query:=
        (:If the query contains any operator used in sandard lucene searches or regex searches, pass it on to the query parser;:) 
        if (functx:contains-any-of($query-string, ('AND', 'OR', 'NOT', '+', '-', '!', '~', '^', '.', '?', '*', '|', '{','[', '(', '<', '@', '#', '&amp;')) and $mode eq 'any')
        then 
            let $luceneParse := app:parse-lucene($query-string)
            let $test3 := console:log($query-string)
             let $test4 := console:log($luceneParse)
            let $luceneXML := util:parse($luceneParse)
            let $lucene2xml := app:lucene2xml($luceneXML/node(), $mode)
            return $lucene2xml
        (:otherwise the query is performed by selecting one of the special options (any, all, phrase, near, fuzzy, wildcard or regex):)
        else
            let $query-string := tokenize($query-string, '\s')
             let $test5 := console:log($query-string)
            let $last-item := $query-string[last()]
            let $query-string :=  string-join($query-string, ' ')
           let $test6 := console:log($query-string)
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
                            then (<phrase>{$query-string}</phrase>, console:log(<phrase>{$query-string}</phrase>))
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
            return ($query, console:log($query))
    return ($query, console:log($query))
    
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
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-fast-backward"/></a>
                </li>,
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ) else (
                <li>
                    <a href="?{$params}&amp;start=1"><i class="glyphicon glyphicon-fast-backward"/></a>
                </li>,
                <li>
                    <a href="?{$params}&amp;start={max( ($start - $per-page, 1 ) ) }"><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ),
            let $startPage := xs:integer(ceiling($start div $per-page))
            let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
            let $upperBound := min(($lowerBound + $max-pages - 1, $count))
            let $lowerBound := max(($upperBound - $max-pages + 1, 1))
            for $i in $lowerBound to $upperBound
            return
                if ($i = ceiling($start div $per-page)) then
                    <li class="active"><a href="?{$params}&amp;start={max( (($i - 1) * $per-page + 1, 1) )}">{$i}</a></li>
                else
                    <li><a href="?{$params}&amp;start={max( (($i - 1) * $per-page + 1, 1)) }">{$i}</a></li>,
            if ($start + $per-page < count($model("hits"))) then (
                <li>
                    <a href="?{$params}&amp;start={$start + $per-page}"><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a href="?{$params}&amp;start={max( (($count - 1) * $per-page + 1, 1))}"><i class="glyphicon glyphicon-fast-forward"/></a>
                </li>
            ) else (
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a><i class="glyphicon glyphicon-fast-forward"/></a>
                </li>
            )
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
            <div class="row reference ">
               <div class="col-md-4"><a href="lemma/{data($id)}">{$term-name}</a></div>
               <div class="col-md-4">{kwic:summarize($term,<config width="40"/>)}</div>
               <div class="col-md-2"><code>{$term/name()}</code></div>
               <div class="col-md-2">{app:editineXide($id, <sources>{for $s in root($term)//tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>
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
          <div class="row">
            <div class="col-md-3">
            <div class="col-md-8"><a class="btn btn-primary" role="button" href="?{$params}&amp;id={data($id)}">{$hom || $term-name}</a></div>
            <div class="col-md-4"><span class="badge"> {count($expanded//exist:match)}</span></div>
            </div>
             <div class="col-md-9">
             <div class="col-md-9">{kwic:summarize($term,<config width="40"/>)}</div>
             <div class="col-md-3">{app:editineXide($id, <sources>{for $s in root($term)//tei:sense return <source lang="{$s/@xml:lang}" value="{$s/@source}"></source>}</sources>)}</div>
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


declare function app:guidelines($node as node()*, $model as map(*)){
<div class="col-md-12">
    <h3>Guidelines</h3>
    <div class="container-fluid">
            <table class="table table-hover">
        <thead>
            <tr>
                <th>Hit the button to get the symbols...</th>
                <th>... or type all this...</th>
                <th>...and it will be displayed as...</th>
                <th>...because it is transformed into...</th>
                <th>...which is...</th>
                <th>...and by the way...</th>
            </tr>
        </thead>
        <tbody>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Meaning</a></td>
                <td>&lt;A&lt; The first meaning &gt;A&gt;</td>
                <td>
                            <b>A)</b> The first meaning</td>
                <td>
                            <pre>&lt;sense n="A"&gt;The first meaning&lt;/sense&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-sense.html">TEI element sense</a>
                        </td>
                <td>
                            <ul>
                                <li>You can nest as many of this as you want. e.g. &lt;A&lt; this has two submeanings &lt;a&lt; meaning 1 &gt;1&gt; and &lt;2&lt; meaning 2 &gt;2&gt;  &gt;A&gt; </li>
                                <li>The order of the section uses at the first level Upper Case letters, at the second level numbers, at the third level lower case letters and at the third level greek letters.</li>
                                
                                <li>
                    To specify the language of use &lt;Ade&lt; .... &gt;A&gt; for example, where <b>de</b> is 
                    the <a target="_blank" href="https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes">ISO 639-1</a> 
                    code for that language.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Label</a></td>
            
                <td>((vid.))</td>
                <td>
                            <a data-toggle="tooltip" data-title="videas">vid.</a>
                        </td>
                <td>
                            <pre>&lt;lbl expand="videas"&gt;vid.&lt;/lbl&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-lbl.html">TEI element lbl</a>
                        </td>
                <td>
                            <ul>
                                <li>Use one of Dillmann's abbreviation and you will get the tooltip explaining it.</li>
                                <li>Try also <pre>((vid.)) \*gez*ሐሊባ፡\*</pre> to get a direct link to the form you enter, like <a data-toggle="tooltip" data-title="videas">vid.</a>
                                    <a href="L28a2fa17dfc84e0ca31f4e6b7ef90d96">ሐሊባ፡ </a>
                                </li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Grammar Group</a></td>
            
                <td>[[anything you put here]]</td>
                <td>anything you put here, transformed as described here.</td>
                <td>
                            <pre>&lt;gramGrp&gt;anything you put here&lt;/gramGrp&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-gramGrp.html">TEI element gramGrp</a>
                        </td>
                <td>
                            <ul>
                                <li>There is no need to nest these. Use it just to group information.</li>
                                <li>See below case, gender and PoS.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Translation</a></td>
            
                <td>&gt;la&gt;mater&gt;</td>
                <td>
                            <i>
                                <a target="_blank" href="http://www.perseus.tufts.edu/hopper/morph?l=mater&amp;la=la">translation</a>
                            </i>
                        </td>
                <td>
                            <pre>&lt;cit type="translation" xml:lang="en"&gt;&lt;quote&gt;mater&lt;/quote&gt;&lt;/cit&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-cit.html">TEI element cit</a>
                        </td>
                <td>
                            <ul>
                                <li>Remember to specify the language according to  
                    the <a target="_blank" href="https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes">ISO 639-1</a> 
                    code for languages.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Transcription</a></td>
            
                <td>&gt;gez!ʾangotay&gt;</td>
                <td>
                          <b> transcription</b>
                        </td>
                <td>
                            <pre>&lt;cit type="transcription" xml:lang="gez"&gt;&lt;quote&gt;ʾangotay&lt;/quote&gt;&lt;/cit&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-cit.html">TEI element cit</a>
                        </td>
                <td>
                            <ul>
                                <li>Remember to specify the language according to  
                    the <a target="_blank" href="https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes">ISO 639-1</a> 
                    code for languages.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Language</a></td>
            
                <td>\*syr*ܐܰܘܓܺܝ\*</td>
                <td>ܐܰܘܓܺܝ</td>
                <td>
                            <pre>&lt;foreign xml:lang="syr"&gt;ܐܰܘܓܺܝ&lt;/foreign&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-foreign.html">TEI element foreign</a>
                        </td>
                <td>
                            <ul>
                                <li>Notice, the app will know that this is in Syriac.</li>
                                <li>Remember to specify the language according to  
                    the <a target="_blank" href="https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes">ISO 639-1</a> 
                    code for languages.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Reference</a></td>
            
                <td>*Matth.|1.1*</td>
                <td>
                            <a ref="Matth.1,1" data-toggle="tooltip" title="" data-original-title="Matthaei Evangelium.">Matth. 1,1</a>
                    <a class="reference" data-ref="Matth.1,1" data-bmid="LIT1558Matthew" data-value="LIT1558Matthew/1/1">
                    <i class="fa fa-file-text-o" aria-hidden="true"/>
                            </a>
                    </td>
                <td>
                            <pre>&lt;ref cRef="Matth." loc="1.1"&gt;Matth. 1.1&lt;/ref&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-ref.html">TEI element ref</a>
                        </td>
                <td>
                            <ul>
                                <li>Eventually, if there is a text, you will see in the popup the line(s) you are quoting.</li>
                                <li>you might find also this notation *Kuf. |35*p.|, this is for where a unit is specified by Dillmann.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td>no button here</td>
                <td>{'|{Dil.1234}|'}</td>
                <td>
                            <i class="fa fa-columns" aria-hidden="true"/>n. 1327 </td>
                <td>
                            <pre>&lt;cb n="1327"/&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-cb.html">TEI element cb</a>
                        </td>
                <td>
                            <ul>
                                <li>Unless there is something to fix, it is very unlikely that you are going to use this</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td>no button here</td>
                <td>{'{Dil.1234}'}</td>
                <td>
                            <a href="#" class="internalLink" data-value="c1327">1327 </a></td>
                <td>
                            <pre>&lt;ref target="#1327"/&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-ref.html">TEI element ref</a>
                        </td>
                <td>
                            <ul>
                                <li>You can use this to make a simple column reference into a link to that column, which is useful if the entry starts several columns before.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Bibliography</a></td>
            
                <td>[§,73]bm:Dillmann1857Gramm</td>
                <td>
                            <a class="Zotero Zotero-citation" data-value="bm:Dillmann1857Gramm" href="https://www.zotero.org/groups/ethiostudies/items/tag/bm:Dillmann1857Gramm">Dillmann 1857</a>
                        </td>
                <td>
                            <pre>&lt;bibl&gt;&lt;ptr target="bm:Dillmann1857Gramm"/&gt;&lt;citedRange unit="paragraph"&gt;73&lt;/citedRange&gt;&lt;/bibl&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-bibl.html">TEI element bibl</a>
                        </td>
                <td>
                            <ul>
                                <li>The bm: part must be a <a href="https://zotero.org/groups/358366/">unique tag in the Ethio Studies Group Zotero</a> Library! </li>
                                <li>If you only want to give a reference to a work omit the [] part, simply add bm:Dillmann1857Gramm</li>
                                <li>p., s., n. $ before comma will be normalized to the allowed values of citedRange page, item and paragraph respectively.</li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">PoS</a></td>
            
                <td>+refl.+</td>
                <td>
                            <a data-toggle="tooltip" data-title="reflexivum" data-original-title="" title="">refl.</a>
                        </td>
                <td>
                            <pre>&lt;pos expand="reflexivum"&gt;refl.&lt;/pos&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-pos.html">TEI element pos</a>
                        </td>
                <td>
                            <ul>
                                <li>This must be inside a gramGrp element! e.g. [[+refl.+ @acc.@ ˆm.ˆ]] </li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Case</a></td>
            
                <td>@acc.@</td>
                <td>
                            <a data-toggle="tooltip" data-title="accusativus">Acc.</a>
                        </td>
                <td>
                            <pre>&lt;case value="accusativus"&gt;acc.&lt;/case&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-case.html">TEI element case</a>
                        </td>
                <td>
                            <ul>
                                <li>This must be inside a gramGrp element! e.g. [[+refl.+ @acc.@ ˆm.ˆ]] </li>
                            </ul>
                        </td>
            </tr>
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">Gender</a></td>
            
                <td>ˆfem.ˆ</td>
                <td>
                            <a data-toggle="tooltip" data-title="femininus">fem.</a>
                        </td>
                <td>
                            <pre>&lt;gen value="femininus"&gt;fem.&lt;/gen&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-gen.html">TEI element gen</a>
                        </td>
                <td>
                            <ul>
                                <li>This must be inside a gramGrp element! e.g. [[+refl.+ @acc.@ ˆm.ˆ]] </li>
                            </ul>
                        </td>
            </tr>
            
            <tr>
            <td><a href="#" class="btn btn-primary btn-sm">ND</a></td>
            
                <td>{'{ND}'}</td>
                <td><a href="#" class="btn btn-success">New</a></td>
                <td>
                            <pre>&lt;nd/&gt;</pre>
                        </td>
                <td>
                            This is an elment not defined by TEI, but added to the schem from TraCES
                        </td>
                <td>
                            <ul>
                                <li>This should be in any entry which is not in Dillmann. You can click the button to add it.</li>
                            </ul>
                        </td>
            </tr>
            
            <tr>
            <td>no button</td>
            
                <td>!!I am a generic note!!</td>
                <td>I am a generic note</td>
                <td>
                            <pre>&lt;note&gt;I am a generic note&lt;/note&gt;</pre>
                        </td>
                <td>
                            <a target="_blank" href="www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-note.html">TEI element note</a>
                        </td>
                <td>
                            <ul>
                                <li>Do you really need this? I doubt, but there are things there which are not better specified. Perhaps specify them in one of the above or suggest something new!</li>
                            </ul>
                        </td>
            </tr>
        </tbody>
    </table>
        </div>
</div>
};

declare function app:footer($node as element(), $model as map(*)){
 <footer>
            <div class="row-fluid">
                <div class="col-md-8">
                    <p>
                    This search uses the exist-db Shakespeare demo app lucene functions slightly modified. You can enter a string and select a mode or use standard Lucene special characters as in the info box.
                </p>
                <p>This project was started and carried on by Alessandro Bausi, Andreas Ellwardt and many others. </p>
                </div>
                <div class="col-md-4">
                    <a class="poweredby" href="http://exist-db.org">
                    <img src="$shared/resources/images/powered-by.svg" alt="Powered by eXist-db"/>
                </a>
                    <a class="poweredby" href="http://www.tei-c.org/">
                        <img src="http://www.tei-c.org/About/Badges/We-use-TEI.png" alt="We use TEI"/>
                    </a>
                    <a class="poweredby" href="https://www.traces.uni-hamburg.de/en.html">
                        <img src="/Dillmann/resources/images/traces.png" alt="Powered by eXist-db"/>
                    </a>
                </div>
            </div>
         
            
        </footer>
        };
  declare function app:NavB($node as element(), $model as map(*)){
 <nav class="navbar navbar-default" role="navigation">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"/>
                    <span class="icon-bar"/>
                    <span class="icon-bar"/>
                </button>
                <a class="navbar-brand" href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/">{$config:expath-descriptor/expath:title/text()}</a>
            </div>
            <div class="navbar-collapse collapse" id="navbar-collapse-1">
                <ul class="nav navbar-nav">
                    
                     
                     {
                      if(xmldb:get-current-user() = 'guest') then
 <li class="dropdown">
          <a href="#" 
          class="dropdown-toggle" 
          data-toggle="dropdown"><b>Login</b> 
          <span class="caret"></span></a>
			<ul id="login-dp" class="dropdown-menu">
				<li>
		 <div class="row">
			<div class="col-md-12">
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
 (: goese with login button, had to put it here to comment it out...
	<a class="btn btn-primary"  href="/Dillmann/createaccount.html">Create a new account</a>
		:)
                else
              <li  class="dropdown"> 
              <form method="post" action="" class="navbar-form" role="form" accept-charset="UTF-8" id="logout-nav">
               <input value="true" name="logout" class="form-control" type="hidden"/>
                        
              <button  class="btn btn-primary btn-xs" type="submit">Logout</button>
              </form>
              </li>
                     }
                     <li id="greetings">
                        <a href="#">
                            Hi {xmldb:get-current-user()}!
                        </a>
                    </li>
                    <li class="dropdown" id="about">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">About</a>
                        <ul class="dropdown-menu">
                            <li class="list-group-item">
                                <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/about.html">About this app</a>
                            </li>
                            <li  class="list-group-item">
                                <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/DillmannProlegomena.html">Dillmann Prolegomena</a>
                            </li>
                        </ul>
                    </li>
                    <li id="list">
                        <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/list">Browse</a>
                    </li>
                    
                    <li id="reverse">
                        <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/reverse">Reverse Index</a>
                    </li>
                    <li id="abbreviations">
                        <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/abbreviations">Abbreviations</a>
                    </li>
                    <li id="quotes">
                        <a href="http://betamasaheft.aai.uni-hamburg.de/Dillmann/citations">Citations</a>
                    </li>
                    <li id="BM">
                        <a href="http://betamasaheft.aai.uni-hamburg.de/" target="_blank">Beta maṣāḥǝft</a>
                    </li>
                </ul>
                
                <form action="/Dillmann/search.html" class="navbar-form navbar-input-group" role="search">
                    <div class="input-group">
                        <input type="text" class="form-control diacritics" placeholder="search" name="q" id="q"/>
                        <span class="input-group-btn">
                        <a class="kb btn btn-success">
                                <i class="fa fa-keyboard-o" aria-hidden="true"></i>
                                </a>
                               <button id="f-btn-search" type="submit" class="btn btn-primary">
                                <i class="fa fa-search" aria-hidden="true"/>
                            </button>
                            <a href="/Dillmann/advanced-search.html" title="advanced search" class="btn btn-default">
                                <i class="fa fa-cog" aria-hidden="true"/>
                            </a>
                            <a href="#" class="btn btn-default" data-toggle="modal" data-target="#searchHelp">
                                <i class="fa fa-info-circle" aria-hidden="true"/>
                            </a>
                            <a class="btn btn-warning" href="https://github.com/SChAth/dillmann/issues/new?title=something%20is%20very%20wrong&amp;assignee=PietroLiuzzo">
                                <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                            </a>
                        </span>
                    </div>
                </form>
            </div>
            
        </nav>};
 
 declare function app:modals($node as element(), $model as map(*)){
   <div id="versionInfo" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">close</button>
                        <h4 class="modal-title">This is a testing and dev website!</h4>
                    </div>
                    <div class="modal-body">
                        <p>        You are looking at a pre-alpha version of this website. If you are not an editor you should not even be seeing it at all. For questions <a href="mailto:pietro.liuzzo@uni-hamburg.de?Subject=Issue%20Report%20BetaMasaheft">contact the dev team</a>.</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        };
        
         declare function app:searchhelp($node as element(), $model as map(*)){
        <div class="modal fade" id="searchHelp" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Search and Input Help</h5>
                    </div>
                    <div class="modal-body">
                    <div>
                    <h3>Search</h3>
                        <p>This app is built with exist-db, and uses Lucene as the standard search engine. This comes with several options available. A full list is <a href="https://lucene.apache.org/core/2_9_4/queryparsersyntax.html#Fuzzy Searches" target="_blank">here</a>
                        </p>
                        <p>Below very few examples.</p>
                        <table class="table table-hover table-responsive">
                            <thead>
                                <tr>
                                    <th/>
                                    <th>sample</th>
                                    <th>result</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>*</td>
                                    <td>*custodir*</td>
                                    <td>add wildcards to unlimit your string search</td>
                                </tr>
                                <tr>
                                    <td>?</td>
                                    <td>custodir?</td>
                                    <td>Will find any match for the position with the question mark.</td>
                                </tr>
                                <tr>
                                    <td>~</td>
                                    <td>ܐܰܘܓܺܝ~</td>
                                    <td>Will make a fuzzy search.</td>
                                </tr>
                                <tr>
                                    <td>""</td>
                                    <td>"ምሕረትከ፡ ይትኖለወኒ፡"</td>
                                    <td>Will find the exact string contained between quotes.</td>
                                </tr>
                                <tr>
                                    <td>()</td>
                                    <td>(verbo OR notionem) AND ܐܰܘܓܺܝ</td>
                                    <td>Will find one of the two between brackets and the other string.</td>
                                </tr>
                            </tbody>
                        </table>
                        </div>
                        <div>
                        <h3>Go To Column</h3>
                        <p>Use this to select the number of the column in the dillmann lexicon you wish to navigate to. It does not make a lot of sense to use this if you are searching a string.</p>
                        </div>
                        
                        <div>
                        <h3>Search only in citations</h3>
                        <p>Ticking this option will search only into <pre>ref</pre> elements, i.e. you are searching for citations of lets say Exodus. You tick this and search "Ex." and you will get all places where this citation has been correctly marked. There might be more!</p>
                        </div>
                        <div>
                        <h3>Advanced options</h3>
                        <p>Click on the plus button to get more filters. You can check which one you want ONLY . You can also switch the not slider to select the ones you want to exclude instead of those you want to have. If you want all the terms which do not contain text in greek swich not and tick greek. If you want all the entries wich contain text in syriac or in coptic tick syriac and coptic, which does not mean you will not get entries which have the other valuess as well as the ones you picked.</p>
                        </div>
                        <div>
                        <h3>Input</h3>
                        <p>If you want to transcribe some fidal into latin or update your transcription, you can <a target="_blank" href="/transcription.html">have a go with our transcription tools</a>.</p>
                        <p>If you are using the keyboard provided, please note that there are four layers, the normal one and those activated by Shift, Alt, Alt+Shift.</p>
                        <p>Normal and Shift contain mainly Fidal. Alt and Alt-Shift diacritics.</p>
                        <p>To enter letters in Fidal and the diacrics with this keyboard, which is independent of your local input selection, you can use two methods.</p>
                        <h4>Keys Combinations</h4>
                        <p>With this method you use keys combinations to trigger specific characters. 
                        <a target="_blank" href="/combos.html">Click here for a list of the available combos.</a> 
                        This can be expanded<a target="_blank" href="https://github.com/SChAth/ScAthiop/issues/new?labels=keyboard&amp;assignee=PietroLiuzzo&amp;body=Please%20add%20a%20combo%20in%20the%20input%20keyboard">, do not hesitate to ask (click here to post a new issue).</a>
                        </p>
                         <h4>Hold and choose</h4>
                         <p>If you hold a key optional values will appear in a list. You can click on the desiderd value or use arrows and enter to select it. The options are the same as those activated by combinations.</p>
                         <p>With this method you do not have to remember or lookup combos, but it does take many more clicks...</p>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        };

