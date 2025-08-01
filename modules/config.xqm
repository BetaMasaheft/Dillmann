xquery version "3.0";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config";

declare namespace repo = "http://exist-db.org/xquery/repo";
declare namespace expath = "http://expath.org/ns/pkg";
declare namespace jmx = "http://exist-db.org/jmx";

import module namespace http = "http://expath.org/ns/http-client" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";
import module namespace templates = "http://exist-db.org/xquery/html-templating";
import module namespace lib = "http://exist-db.org/xquery/html-templating/lib";

declare variable $config:ADMIN := environment-variable("ExistAdmin");

declare variable $config:ppw := environment-variable("ExistAdminPw");

declare variable $config:appUrl := "https://betamasaheft.eu";

declare variable $config:sparqlPrefixes :=
  "PREFIX lexicog: <http://www.w3.org/ns/lemon/lexicog#>
        PREFIX ontolex: <http://www.w3.org/ns/lemon/ontolex#>
        PREFIX vartrans: <http://www.w3.org/ns/lemon/vartrans#>
         PREFIX lime: <http://www.w3.org/ns/lemon/lime#>
         PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
         PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
         PREFIX owl: <http://www.w3.org/2002/07/owl#>
         PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
         PREFIX void: <http://rdfs.org/ns/void#>
         PREFIX dc: <http://purl.org/dc/elements/1.1/>
         PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
         PREFIX lexinfo: <http://www.lexinfo.net/ontology/2.0/lexinfo#>
         PREFIX dillmann: <https://betamasaheft.eu/Dillmann/>
         PREFIX traces: <https://betamasaheft.eu/morpho/>
        PREFIX oa: <http://www.w3.org/ns/oa#>
        PREFIX bm: <https://betamasaheft.eu/>
        ";

declare variable $config:response200 := <rest:response>
  <http:response status="200">
    <http:header name="Access-Control-Allow-Origin" value="*" />
  </http:response>
</rest:response>;

declare variable $config:response200Json := <rest:response>
  <http:response status="200">
    <http:header name="Content-Type" value="application/json; charset=utf-8" />
    <http:header name="Access-Control-Allow-Origin" value="*" />
  </http:response>
</rest:response>;

declare variable $config:response200XML := <rest:response>
  <http:response status="200">
    <http:header name="Content-Type" value="application/xml; charset=utf-8" />
    <http:header name="Access-Control-Allow-Origin" value="*" />
  </http:response>
</rest:response>;

declare variable $config:response400 := <rest:response>
  <http:response status="400">
    <http:header name="Content-Type" value="application/json; charset=utf-8" />
  </http:response>
</rest:response>;

declare variable $config:response400XML := <rest:response>
  <http:response status="400">
    <http:header name="Content-Type" value="application/xml; charset=utf-8" />
  </http:response>
</rest:response>;

(:
    Determine the application root collection from the current module load path.
 :)
declare variable $config:app-root := let $rawPath :=
system:get-module-load-path()
let $modulePath := (: strip the xmldb: part :) if (
  starts-with($rawPath, "xmldb:exist://")
) then
  if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
    substring($rawPath, 36)
  else
    substring($rawPath, 15)
else
  $rawPath
return substring-before($modulePath, "/modules");

declare variable $config:data-root := "/db/apps/DillmannData";

declare variable $config:collection-root := collection($config:data-root);

declare variable $config:repo-descriptor := doc(
  concat($config:app-root, "/repo.xml")
)/repo:meta;

declare variable $config:expath-descriptor := doc(
  concat($config:app-root, "/expath-pkg.xml")
)/expath:package;

declare variable $config:data := $config:app-root || "/data";

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve ($relPath as xs:string) {
  if (starts-with($config:app-root, "/db")) then
    doc(concat($config:app-root, "/", $relPath))
  else
    doc(concat("file://", $config:app-root, "/", $relPath))
};

declare function config:get-configuration () as element(configuration) {
  doc(concat($config:app-root, "/configuration.xml"))/configuration
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor () as element(repo:meta) {
  $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor () as element(expath:package) {
  $config:expath-descriptor
};

declare %templates:wrap function config:app-title (
  $node as node(),
  $model as map(*)
) as text() {
  $config:expath-descriptor/expath:title/text()
};

declare function config:app-meta (
  $node as node(),
  $model as map(*)
) as element()* {
  <meta
    xmlns="http://www.w3.org/1999/xhtml"
    content="{ $config:repo-descriptor/repo:description/text() }"
    name="description" />,
  for $author in $config:repo-descriptor/repo:author
  return <meta
      xmlns="http://www.w3.org/1999/xhtml"
      content="{ $author/text() }"
      name="creator" />
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info ($node as node(), $model as map(*)) {
  let $expath := config:expath-descriptor()
  let $repo := config:repo-descriptor()
  return <table class="app-info">
      <tr><td>app collection:</td><td>{ $config:app-root }</td></tr>
      {
        for $attr in ($expath/@*, $expath/*, $repo/*)
        return <tr>
            <td>{ node-name($attr) }:</td>
            <td>{ $attr/string() }</td>
          </tr>
      }
      <tr>
        <td>Controller:</td>
        <td>{ request:get-attribute("$exist:controller") }</td>
      </tr>
    </table>
};

declare function config:get-data-dir () as xs:string? {
  try {
    let $request := <http:request
      href="http://localhost:8080/{ request:get-context-path() }/status?c=disk"
      http-version="1.1"
      method="GET" />
    let $response := http:send-request($request)
    return if ($response[1]/@status = "200") then
        let $dir := $response[2]//jmx:DataDirectory/string()
        return if (matches($dir, "^\w:")) then
            (: windows path? :)
            "/" || translate($dir, "\", "/")
          else
            $dir
      else (
      )
  } catch * { () }
};

declare function config:get-repo-dir () {
  let $dataDir := config:get-data-dir()
  let $pkgRoot := $config:expath-descriptor/@abbrev ||
    "-" ||
    $config:expath-descriptor/@version
  return if ($dataDir) then
      $dataDir || "/expathrepo/fonts-0.1"
    else (
    )
};

declare function config:get-fonts-dir () as xs:string? {
  let $repoDir := config:get-repo-dir()
  return if ($repoDir) then
      $repoDir || "/fonts"
    else (
    )
};
