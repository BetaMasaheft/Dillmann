xquery version "3.0";
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/dict/config" at "modules/config.xqm";
import module namespace request = "http://exist-db.org/xquery/request";

import module namespace console="http://exist-db.org/xquery/console";

declare namespace t = "http://www.tei-c.org/ns/1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
    (: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    
     (: Requests for javascript libraries are resolved to the file system :)
else
    if (contains($exist:path, "resources/")) 
    then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/resources/{substring-after($exist:path, 'resources/')}"/>
        </dispatch>
        
        
    
    else
                if (ends-with($exist:path, ".xml")) then
                    <dispatch
                        xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward
                            url="/{substring-after(base-uri(collection($config:data-root)//id(substring-before($exist:resource, '.xml'))), 'db/apps/')}"/>
                    </dispatch>


else if (contains($exist:path,'/api/')) then
  if (ends-with($exist:path,"/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="/apidoc.html"/>
    </dispatch>
   else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat('/restxq/dict', $exist:path)}" absolute="yes"/>
    </dispatch>
    else if ($exist:path eq "/list") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-items.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/new") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-new.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/citations") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-quotations.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/abbreviations") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-abbreviations.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/languages") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-languages.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    
    else if (ends-with($exist:resource, ".pdf")) then
    let $id := substring-before($exist:resource, '.pdf')
    return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/modules/tei2fo.xql">
                    <add-parameter name="id" value="{$id}"/>
                </forward>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
    
else
                            if (contains($exist:path, "lemma/")) then
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="{$exist:controller}/view-item.html"/>
                                   <view>
            <forward url="{$exist:controller}/modules/view.xql">
            <add-parameter
                                                name="id"
                                                value="{$exist:resource}"/>
                                    </forward>
        </view> 
                                </dispatch>    
                             (:   else
                            if (contains($exist:path, "update/")) then
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="{$exist:controller}/edit/edit.xq">
                                        <add-parameter
                                                name="new"
                                                value="false"/>
                                   <add-parameter
                                                name="id"
                                                value="{$exist:resource}"/>
                                    </forward>
                                    
                                </dispatch> :)
                                
                               (: else
                            if ($exist:resource eq "update.xq") then
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="{$exist:controller}/edit/update.xq">
                                        <add-parameter
                                                name="id"
                                                value="{request:get-parameter('id', ())}"/>
                                   <add-parameter
                                                name="submissionResponse"
                                                value="{request:get-parameter('submissionResponse', ())}"/>
                                   <add-parameter
                                                name="sessionKey"
                                                value="{request:get-parameter('sessionKey', ())}"/>
                                    </forward>
                                    
                                </dispatch>:) 
                                    
           
else     if ($exist:path eq "/") then
                <dispatch
                    xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward
                        url="{$exist:controller}/index.html">
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
    
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
