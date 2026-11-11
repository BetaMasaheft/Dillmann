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
let $backup-collection := concat($target, "/EditorBackups")
let $_ := if (not(xmldb:collection-available($backup-collection))) then
  xmldb:create-collection($target, "EditorBackups")
else (
)

(: Capture external-service endpoint overrides while running as DBA:
   fn:environment-variable is a DBA-only read in eXist, so request-time code
   (guest) cannot see these. config:service-url() reads the stored document
   instead and falls back to its default when a variable was not set.
   The image deploys the xar via /exist/autodeploy, so this runs on first
   container start, when the runtime environment is set. :)
let $services := <services>
  {
    for $env in ("ID_MANAGER_URL")
    let $value := environment-variable($env)
    where normalize-space($value) ne ""
    return <service env="{ $env }">{ normalize-space($value) }</service>
  }
</services>

return (
  xmldb:store($target, "services.xml", $services),
  (: guest must be able to read but never write this document: it holds
     URLs the server itself will POST to :)
  sm:chmod(xs:anyURI($target || "/services.xml"), "rw-r--r--")
)
