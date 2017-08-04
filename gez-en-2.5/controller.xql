xquery version "3.0";
import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "modules/config.xqm";

import module namespace console="http://exist-db.org/xquery/console";

declare namespace t = "http://www.tei-c.org/ns/1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


declare variable $login :=
    let $tryImport :=
        try {
            util:import-module(xs:anyURI("http://exist-db.org/xquery/login"), 
            "login", xs:anyURI("resource:org/exist/xquery/modules/persistentlogin/login.xql")),
            true()
        } catch * {
            false()
        }
    return
        if ($tryImport) then
            function-lookup(xs:QName("login:set-user"), 3)
        else
            local:fallback-login#3
;



(:~
    Fallback login function used when the persistent login module is not available.
    Stores user/password in the HTTP session.
 :)
declare function local:fallback-login($domain as xs:string, $maxAge as xs:dayTimeDuration?, $asDba as xs:boolean) {
    let $user := request:get-parameter("user", ())
    let $password := request:get-parameter("password", ())
    let $logout := request:get-parameter("logout", ())
    return
        if ($logout) then
            (
            session:invalidate(),
             console:log('logout'),
             console:log('I have just logged out. This list of SESSION attributes should be empty ' ||string-join(session:get-attribute-names(), ' '))
                        
             )
       else
            if ($user) then
                let $isLoggedIn := xmldb:login("/db", $user, $password, true())
                return (
                        session:set-attribute("dict.user", $user),
                        session:set-attribute("dict.password", $password),
                        request:set-attribute($domain || ".user", $user),
                        request:set-attribute("xquery.user", $user),
                        request:set-attribute("xquery.password", $password),
                        console:log(if(session:exists()) then 'yes' else 'no'),
                        console:log('I have just set user param. These are the REQUEST attributes ' ||string-join(request:attribute-names(), ' ')),
                        console:log('I have just set user param. These are the SESSION attributes ' ||string-join(session:get-attribute-names(), ' '))
                        
                        )
                   
            else
                let $user := session:get-attribute("dict.user")
                let $password := session:get-attribute("dict.password")
                return (
                    request:set-attribute($domain || ".user", $user),
                    request:set-attribute("xquery.user", $user),
                    request:set-attribute("xquery.password", $password),
                        console:log('No user param. These are the REQUEST attributes ' || string-join(request:attribute-names(), ' ')),
                        console:log('No user param. These are the SESSION attributes' || string-join(session:get-attribute-names(), ' '))
                )
};

declare function local:user-allowed() {
    (
        request:get-attribute("org.exist.login.user") and
        request:get-attribute("org.exist.login.user") != "guest"
    ) or config:get-configuration()/restrictions/@guest = "yes"
};

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
        <forward url="{concat('/restxq/gez-en', $exist:path)}" absolute="yes"/>
    </dispatch>
    else if ($exist:path eq "/list") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-items.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/new") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-items.html">
                                        <add-parameter name="new" value="true"/>
                                        </forward>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/citations") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-quotations.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
     else if ($exist:path eq "/reverse") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/reverse.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
    else if ($exist:path eq "/abbreviations") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
                                        url="{$exist:controller}/list-abbreviations.html"/>
                                        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>
   
    
    else if (ends-with($exist:resource, ".pdf")) then
    let $id := substring-before($exist:resource, '.pdf')
    return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/modules/tei2fo.xql">
                 {$login("org.exist.login", (), false())}
            <set-header name="Cache-Control" value="no-cache"/>
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
                                        url="{$exist:controller}/view-item.html">
                                        {$login("org.exist.login", (), false())}
            <set-header name="Cache-Control" value="no-cache"/>
                                        </forward>
                                   <view>
            <forward url="{$exist:controller}/modules/view.xql">
            
            <add-parameter
                                                name="id"
                                                value="{$exist:resource}"/>
                                    </forward>
        </view> 
                                </dispatch>    
                            
                                    
        
else  if ($exist:path eq "/") then 
                <dispatch
                    xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward
                        url="{$exist:controller}/index.html">
                         {$login("org.exist.login", (), false())}
            <set-header name="Cache-Control" value="no-cache"/>
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
            <forward url="{$exist:controller}/modules/view.xql">
             {$login("org.exist.login", (), false())}
            <set-header name="Cache-Control" value="no-cache"/>
            </forward>
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
