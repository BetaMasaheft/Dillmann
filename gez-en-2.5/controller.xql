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


if ($exist:path eq '') then
    <dispatch
        xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect
            url="{request:get-uri()}/"/>
    </dispatch>
    
    (: Resource paths starting with $shared are loaded from the shared-resources app :)
else
    if (contains($exist:path, "/$shared/")) then
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
                <set-header
                    name="Cache-Control"
                    value="max-age=3600, must-revalidate"/>
            </forward>
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
        if (contains($exist:path, "resources/"))
        then
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{$exist:controller}/resources/{substring-after($exist:path, 'resources/')}"/>
            </dispatch>
        
        
        
        else
            if (ends-with($exist:path, ".xml")) then
                <dispatch
                    xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward
                        url="/{substring-after(base-uri(collection($config:data-root)//id(substring-before($exist:resource, '.xml'))), 'db/apps/')}"/>
                </dispatch>
            
            
            else
                if (contains($exist:path, '/api/')) then
                    if (ends-with($exist:path, "/")) then
                        <dispatch
                            xmlns="http://exist.sourceforge.net/NS/exist">
                            <redirect
                                url="/Dillmann/apidoc.html"/>
                        </dispatch>
                    else
                        <dispatch
                            xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward
                                url="{concat('/restxq/gez-en', $exist:path)}"
                                absolute="yes"/>
                        </dispatch>
                else
                    if ($exist:path eq "/list") then
                        <dispatch
                            xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward
                                url="{$exist:controller}/list-items.html"/>
                            <view>
                                <forward
                                    url="{$exist:controller}/modules/view.xql"/>
                            </view>
                        </dispatch>
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
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="{$exist:controller}/list-quotations.html"/>
                                    <view>
                                        <forward
                                            url="{$exist:controller}/modules/view.xql"/>
                                    </view>
                                </dispatch>
                            else
                                if ($exist:path eq "/reverse") then
                                    <dispatch
                                        xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward
                                            url="{$exist:controller}/reverse.html"/>
                                        <view>
                                            <forward
                                                url="{$exist:controller}/modules/view.xql"/>
                                        </view>
                                    </dispatch>
                                else
                                    if ($exist:path eq "/abbreviations") then
                                        <dispatch
                                            xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward
                                                url="{$exist:controller}/list-abbreviations.html"/>
                                            <view>
                                                <forward
                                                    url="{$exist:controller}/modules/view.xql"/>
                                            </view>
                                        </dispatch>
                                    
                                    
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
                                                <dispatch
                                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                                    
                                                    <forward
                                                        url="{$exist:controller}/view-item.html">
                                                        {$login("org.exist.login", (), false())}
                                                        <set-header
                                                            name="Cache-Control"
                                                            value="no-cache"/>
                                                    </forward>
                                                    <view>
                                                        <forward
                                                            url="{$exist:controller}/modules/view.xql">
                                                            
                                                            <add-parameter
                                                                name="id"
                                                                value="{$exist:resource}"/>
                                                        </forward>
                                                    </view>
                                                </dispatch>
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
