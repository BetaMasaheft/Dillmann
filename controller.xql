xquery version "3.1";
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "modules/config.xqm";
import module namespace login = "http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";

declare namespace t = "http://www.tei-c.org/ns/1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


declare variable $login :=   login:set-user#3;

declare function local:forward($url) {
<dispatch  xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{$url}" absolute="yes"/>
</dispatch>
};
declare function local:forwardlist($name){
 <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{$exist:controller}/{$name}.html"/>
     <view>
        <forward url="{$exist:controller}/modules/view.xql"/>
     </view>
 </dispatch>};
 
declare function local:redirect($path) {
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <redirect  url="{$path}"/>
 </dispatch>
};
declare function local:viewxql($id){
   <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
         <forward  url="{$exist:controller}/view-item.html">
                 {$login("org.exist.login", (), false())}
              <set-header name="Cache-Control" value="no-cache"/>
          </forward>
           <view>
                  <forward url="{$exist:controller}/modules/view.xql">
                     <add-parameter  name="id" value="{$id}"/>
                  </forward>
           </view>
  </dispatch>
};

if ($exist:path eq '') then
    <dispatch
        xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect
            url="{request:get-uri()}/"/>
    </dispatch>
     
  else if (contains($exist:path, "openapi/")) then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward
      url="/openapi/{ $exist:path => substring-after("/openapi/") => replace("json", "xq") }"
      method="get">
      <add-parameter name="target" value="{ substring-after($exist:root, "://") || $exist:controller }"/>
      <add-parameter name="register" value="false"/>
    </forward>
  </dispatch> 
  
        (: Requests for javascript libraries are resolved to the file system :)
    else
        if (contains($exist:path, "resources/")) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/resources/{substring-after($exist:path, 'resources/')}"/>
            </dispatch>
    else
         if (ends-with($exist:path, ".xml")) then
         let $id := substring-before($exist:resource, '.xml')
                            let $item := $config:collection-root/id($id)
                            let $uri := base-uri($item)
                            return
                            if ($item) then
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="/{substring-after($uri, 'db/apps/')}"/>
                                        <error-handler>
                                                <forward
                                                    url="{$exist:controller}/error/error-page.html"
                                                    method="get"/>
                                                <forward
                                                    url="{$exist:controller}/modules/view.xql"/>
                                            
                                            </error-handler>
                                </dispatch> else ()
            
            
            else
                if (contains($exist:path, '/api/')) then
                    if (ends-with($exist:path, "/")) then
                    local:redirect('/Dillmann/apidoc.html')
                    else
                    local:forward(concat('/restxq/gez-en', $exist:path))
                else
                    if ($exist:path eq "/list") then
                    local:forwardlist('list-items')
                    else
                        if ($exist:path eq "/new") then
                            <dispatch
                                xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward
                                    url="{$exist:controller}/list-items.html">
                                    <add-parameter
                                        name="new"
                                        value="true"/>
                                </forward>
                                <view>
                                    <forward
                                        url="{$exist:controller}/modules/view.xql"/>
                                </view>
                            </dispatch>
                        else
                            if ($exist:path eq "/citations") then
                            local:forwardlist('list-quotations')
                        else
                            if ($exist:path eq "/reverse") then
                            local:forwardlist('reverse')
                        else
                            if ($exist:path eq "/abbreviations") then
                            local:forwardlist('list-abbreviations')
                       else
                            if (ends-with($exist:resource, ".pdf")) then
                            let $id := substring-before($exist:resource, '.pdf')
                                            return
                                                <dispatch
                                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                                    <forward
                                                        url="{$exist:controller}/modules/tei2fo.xql">
                                                        {$login("org.exist.login", (), false())}
                                                        <set-header
                                                            name="Cache-Control"
                                                            value="no-cache"/>
                                                        <add-parameter
                                                            name="id"
                                                            value="{$id}"/>
                                                    </forward>
                                                    <error-handler>
                                                        <forward
                                                            url="{$exist:controller}/error-page.html"
                                                            method="get"/>
                                                        <forward
                                                            url="{$exist:controller}/modules/view.xql"/>
                                                    </error-handler>
                                                </dispatch>
                         else
                              if (contains($exist:path, "lemma/")) then
                             local:viewxql($exist:resource)
                                         
(:                         handles requests which are not directly to xml or html or pdf and redirect according to requested Accept header:)
                           else 
                               if(matches($exist:path, 'L[a-z0-9]{32}')) then
                                 let $accepts := request:get-header('Accept')
                                 return
                                  if (contains($accepts, 'rdf'))
(:            if RDF is requested the request is forwarded to FUSEKI with DESCRIBE for the requested resource
    The request header of the original request should be also passed, so that if a specific format is requested from Fuseki, 
    this should be returned
    
    this covers all request to entities for rdf and rdf formats
:)
                                  then
                                    let $query := $config:sparqlPrefixes || 'DESCRIBE <' || $exist:path || '>'
                                     return 
                                         <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                             <forward url="{concat('/fuseki/dillmann/query?query=', $query)}" absolute="yes"> 
                                                <set-header name="Cache-Control" value="no-cache"/>
                                                { let $headerslist := request:get-header-names()
                                                                      for $header in $headerslist
                                                                    return <set-header 
                                                                    name="{$header}" 
                                                                    value="{request:get-header($header)}"/> }
                                                 </forward>
                                        </dispatch>
                              else if (contains($accepts, 'html')) then       
(:        if html is requested for a request to a concept URI, this should resolve to the correct HTML page, with the correct anchor where possible  :)
                                 ( if(matches($exist:path, 'L[a-z0-9]{32}_entry')) 
(:                               lexicog:Entry should redirect to main page:)
                                   then ( local:viewxql(replace($exist:resource, '_entry', '')) )
                                    else if(matches($exist:path, 'L[a-z0-9]{32}_sense')) 
(:                                      ontolex:LexicalSense:)
                                    then (     let $lastid := analyze-string($exist:resource, '(_sense_)([A-Za-z0-9]+)') return
                                    local:forward(concat('/Dillmann/lemma/',substring-before($exist:resource, '_'), '#', $lastid/*:match[last()]/*:group[@nr='2']/text())))
                                   else if(matches($exist:path, 'L[a-z0-9]{32}_form')) 
(:                                ontolex:Form should redirect to the lemma in the HTML:)
                                   then (local:forward(concat('/Dillmann/lemma/',substring-before($exist:resource, '_'), '#lemma')))
                                 else if(matches($exist:path, 'L[a-z0-9]{32}_comp')) 
(:                                  lexicog:LexicographicComponent should check again for sense or redirect to entry:)
                                       then (
                                                  if(matches($exist:path, '_sense')) 
(:                                                           check again for sense or redirect to entry:)
                                                             then (    let $lastid := analyze-string($exist:resource, '(_sense_)([A-Za-z0-9]+)') return
                                                                local:forward(concat('/Dillmann/lemma/',substring-before($exist:resource, '_'), '#', $lastid/*:match[last()]/*:group[@nr='2']/text())
                                                             ))
(:                                                             if it is not a sense component, then is a  lexicog:LexicographicComponent , redirect to main HTML page:)
                                                             else (
                                                               local:forward(concat('/Dillmann/lemma/',substring-before($exist:resource, '_')))
                                                             )
                                               )              
                                                            else ()
                                                            )
                               else (
(:                          this should cover the basic ontolex:LexicalEntry, with a pattern which simply looks https://betamasaheft.eu/Dillmann/[lemmaid] :)
                                                             local:viewxql($exist:resource)
                                                    )
                            else
                               if (contains($exist:path, "user/")) then
                                                    <dispatch
                                                        xmlns="http://exist.sourceforge.net/NS/exist">
                                                        
                                                        <forward
                                                            url="{$exist:controller}/user.html">
                                                            {$login("org.exist.login", (), false())}
                                                            <set-header
                                                                name="Cache-Control"
                                                                value="no-cache"/>
                                                        </forward>
                                                        <view>
                                                            <forward
                                                                url="{$exist:controller}/modules/view.xql">
                                                                
                                                                <add-parameter
                                                                    name="username"
                                                                    value="{$exist:resource}"/>
                                                            </forward>
                                                        </view>
                                                    </dispatch>
                                                
                                                
                                                
                                                else
                                                    if ($exist:path eq "/") then
                                                        <dispatch
                                                            xmlns="http://exist.sourceforge.net/NS/exist">
                                                            <forward
                                                                url="{$exist:controller}/index.html">
                                                                {$login("org.exist.login", (), false())}
                                                                <set-header
                                                                    name="Cache-Control"
                                                                    value="no-cache"/>
                                                            </forward>
                                                            <view>
                                                                <forward
                                                                    url="{$exist:controller}/modules/view.xql">
                                                                </forward>
                                                            </view>
                                                            <error-handler>
                                                                <forward
                                                                    url="{$exist:controller}/error-page.html"
                                                                    method="get"/>
                                                                <forward
                                                                    url="{$exist:controller}/modules/view.xql"/>
                                                            
                                                            </error-handler>
                                                        </dispatch>
                                                    
                                                    else
                                                        if (ends-with($exist:resource, ".html")) then
                                                            (: the html page is run through view.xql to expand templates :)
                                                            
                                                            <dispatch
                                                                xmlns="http://exist.sourceforge.net/NS/exist">
                                                                <view>
                                                                    <forward
                                                                        url="{$exist:controller}/modules/view.xql">
                                                                        {$login("org.exist.login", (), false())}
                                                                        <set-header
                                                                            name="Cache-Control"
                                                                            value="no-cache"/>
                                                                    </forward>
                                                                </view>
                                                                <error-handler>
                                                                    <forward
                                                                        url="{$exist:controller}/error-page.html"
                                                                        method="get"/>
                                                                    <forward
                                                                        url="{$exist:controller}/modules/view.xql"/>
                                                                </error-handler>
                                                            </dispatch>
                                                        
                                                        else
                                                            (: everything else is passed through :)
                                                            <dispatch
                                                                xmlns="http://exist.sourceforge.net/NS/exist">
                                                                <cache-control
                                                                    cache="yes"/>
                                                            </dispatch>
