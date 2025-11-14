xquery version "3.1";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;

(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;

(: the target collection into which the app is deployed :)
declare variable $target external;

(: Create EditorBackups collection if it doesn't exist :)
let $backup-collection := concat($target, '/EditorBackups')
return
    if (not(xmldb:collection-available($backup-collection))) then
        xmldb:create-collection($target, 'EditorBackups')
    else
        ()

