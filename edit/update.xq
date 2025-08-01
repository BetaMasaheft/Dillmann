xquery version "3.1"  encoding "UTF-8";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace request = "http://exist-db.org/xquery/request";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace l = "http://log.log";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
declare variable $form := request:get-parameter('form', ());
declare variable $sensela := request:get-parameter('sensela', ());
declare variable $senseen := request:get-parameter('senseen', ());
declare variable $id := request:get-parameter('id', ());

let $app-collection := '/db/apps/gez-en'
let $data-collection := '/db/apps/gez-en/data'

let $login := xmldb:login($data-collection, 'Pietro', 'Hdt7.10') 
let $title := 'Update Confirmation'
let $data-collection := '/db/apps/gez-en/data'
 let $targetfileuri := base-uri(collection($data-collection)//id($id))
 let $transForm := replace(replace($form, '/\*gez\*', '<foreign xml:lang="gez">'), '/\*', '</foreign>')
let $updateform :=  update replace doc($targetfileuri)//tei:entry/tei:form with <form xmlns="http://www.tei-c.org/ns/1.0">{$transForm}</form>


return
<html>
    <head>
       <title>{$title}</title>
    </head>
    <body>
    <h1>{$title}</h1>
    <p>Item {$id} has been updated.</p>
    <a href="/Dillmann/lemma/{$id}">{$form}</a>
    </body>
</html>