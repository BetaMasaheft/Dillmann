xquery version "3.1";

import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console";

declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace xslfo = "http://exist-db.org/xquery/xslfo";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace file = "http://exist-db.org/xquery/file";

declare variable $local:fop-config := 
    let $fontsDir := config:get-fonts-dir()
    return
        <fop version="1.0">
            <strict-configuration>true</strict-configuration>
            <strict-validation>false</strict-validation>
            <base>./</base>
            <renderers>
                <renderer mime="application/pdf">
                    <fonts>
                    {
                        if ($fontsDir) then (
                            <font kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Regular.ttf">
                                <font-triplet name="Noto" style="normal" weight="normal"/>
                            </font>,
                            <font kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Bold.ttf">
                                <font-triplet name="Noto" style="normal" weight="700"/>
                            </font>,
                            <font kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Italic.ttf">
                                <font-triplet name="Noto" style="italic" weight="normal"/>
                            </font>,
                            <font kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-BoldItalic.ttf">
                                <font-triplet name="Noto" style="italic" weight="700"/>
                            </font>,
                            <font kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansEthiopic-Regular.ttf">
                                <font-triplet name="NotoSansEthiopic" style="normal" weight="normal"/>
                            </font>,
                            <font kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansEthiopic-Bold.ttf">
                                <font-triplet name="NotoSansEthiopic" style="normal" weight="700"/>
                            </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoNaskhArabic-Regular.ttf">
                    
                    <font-triplet name="NotoNaskhArabic" style="normal" weight="normal"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoNaskhArabic-Bold.ttf">
                    
                    <font-triplet name="NotoNaskhArabic" style="normal" weight="700"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansArmenian-Bold.ttf">
                    
                    <font-triplet name="NotoSansArmenian" style="normal" weight="700"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansArmenian-Regular.ttf">
                    
                    <font-triplet name="NotoSansArmenian" style="normal" weight="normal"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansAvestan-Regular.ttf">
                    
                    <font-triplet name="NotoSansAvestan" style="normal" weight="normal"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansCoptic-Regular.ttf">
                    
                    <font-triplet name="NotoSansCoptic" style="normal" weight="normal"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansGeorgian-Regular.ttf">
                    
                    <font-triplet name="NotoSansGeorgian" style="normal" weight="normal"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansHebrew-Regular.ttf">
                    
                    <font-triplet name="NotoSansHebrew" style="normal" weight="normal"/>
                </font>,
                <font kerning="yes" embed-url="file:{$fontsDir}/NotoSansSyriacEstrangela-Regular.ttf">
                    
                    <font-triplet name="NotoSansSyriacEstrangela" style="normal" weight="normal"/>
                </font>
                        ) else
                            ()
                    }
                    </fonts>
                </renderer>
            </renderers>
        </fop>
;
declare function fo:tei2fo($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case element(tei:TEI) return
                fo:tei2fo($node/tei:text)
            case element(tei:text) return
                fo:tei2fo($node//tei:body)
            case element(tei:div) return
                    <fo:block id="{generate-id($node)}" font-family="Noto">
                        {fo:tei2fo($node/node())}
                    </fo:block>
                    case element(tei:entry) return
                    <fo:block font-family="Noto" font-size="12pt" text-indent="1cm">
                    {fo:tei2fo($node/node())}
                    </fo:block>
            case element(tei:form) return 
            <fo:inline font-family="NotoSansEthiopic" font-weight="bold" font-size="12pt">
            {$node//text()}
            </fo:inline>
            case element(tei:foreign) return 
            <fo:inline > 
            {switch($node/@xml:lang) 
            case 'ar' return (attribute font-family {'NotoNaskhArabic'}, attribute writing-mode {'rl'}) 
            case 'he' return (attribute font-family {'NotoSansHebrew'}, attribute writing-mode {'rl'}) 
            case 'syr' return (attribute font-family {'NotoSansSyriacEstrangela'}, attribute writing-mode {'rl'}) 
            case 'cop' return attribute font-family {'NotoCoptic'} 
            case 'gez' return attribute font-family {'NotoSansEthiopic'} 
            default return attribute font-family {'Noto'}}
            {$node//text()}
            </fo:inline>  
            case element(tei:cb) return
            <fo:inline >{'{DiL.'|| string($node/@n)||'}'} </fo:inline>
            case element(tei:cit) return
            <fo:inline font-style="italic" >{fo:tei2fo($node/node())} </fo:inline>
            case element(tei:ref) return
            if($node/@target) then (<fo:inline >{'{DiL'|| replace($node/@target, '#c', '.') || '}'} </fo:inline>)
            else fo:tei2fo($node/node())
            case element(tei:bibl) return
            <fo:inline >{string($node/tei:ptr/@target)}</fo:inline>
             case element(tei:sense) return 
 (if($node/@source  = '#traces') then (<fo:inline  font-weight="bold">TraCES {string($node/@xml:lang)}</fo:inline>) else (),
 if($node/@n) then (<fo:inline font-weight="bold">{string($node/@n) || ')'} </fo:inline>) else (),
                        fo:tei2fo($node/node()))
                  
            case element() return
                fo:tei2fo($node/node())
            default return
                $node
};

declare function fo:footer($form as element(tei:form)){
<fo:inline font-family="NotoSansEthiopic">{$form//text()}</fo:inline>
};
declare function fo:speech($speech as element(tei:sp)) {
    <fo:block space-after="1em">
        <fo:block space-after=".25em">
            <fo:inline space-end="1em" font-style="italic">{$speech/tei:speaker/text()}</fo:inline>
            <fo:inline>{$speech/(tei:l|tei:ab)[1]/text()}</fo:inline>
        </fo:block>
        {
            for $line in $speech/(tei:l|tei:ab)[position() > 1]
            return
                <fo:block space-after=".25em" margin-left=".75em">{fo:tei2fo($line)}</fo:block>
        }
    </fo:block>
};

declare function fo:titlepage($header as element(tei:teiHeader))   {
    <fo:page-sequence master-reference="Shakespeare">
        <fo:flow flow-name="xsl-region-body" font-family="Noto">
            <fo:block font-size="44pt" text-align="center">
            {                     
                $header/tei:fileDesc/tei:titleStmt/tei:title/text() 
            }
            </fo:block> 
            <fo:block text-align="center" font-size="20pt" font-style="italic" space-before="2em" space-after="2em">
            by
            </fo:block>
            <fo:block text-align="center" font-size="30pt" font-style="italic" space-before="2em" space-after="2em">
            {                  
                $header/tei:fileDesc/tei:titleStmt/tei:author/text() 
            }
            </fo:block>
            <fo:block text-align="center" space-before="2em" space-after="2em">
            <!--fo:external-graphic content-height="300pt" src="http://data.stonesutras.org:8600/exist/apps/shakes/resources/images/shakespeare-french.jpg"/-->    
            </fo:block>
        </fo:flow>                    
    </fo:page-sequence>
};

declare function fo:table-of-contents($work as element(tei:TEI)) {
    <fo:page-sequence master-reference="Shakespeare">
        <fo:flow flow-name="xsl-region-body" font-family="Noto">
        <fo:block font-size="30pt" space-after="1em" font-family="Noto">Table of Contents</fo:block>
        {
            for $act at $act-count in $work/tei:text/tei:body/tei:div
            return
                <fo:block space-after="3mm">
                    <fo:block text-align-last="justify">
                        {$act/tei:head/text()}
                        <fo:leader leader-pattern="dots"/>
                        <fo:page-number-citation ref-id="{generate-id($act)}"/>
                    </fo:block>
                    {
                        for $scene at $scene-count in $act/tei:div
                        return
                            <fo:block text-align-last="justify" margin-left="4mm">
                                {$scene/tei:head/text()}
                                <fo:leader leader-pattern="dots"/>
                                <fo:page-number-citation ref-id="{generate-id($scene)}"/>
                            </fo:block>
                    }
                </fo:block>
        }
        </fo:flow>
    </fo:page-sequence>
};

declare function fo:cast($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case element(tei:castList) return
                <fo:block space-after="4mm">
                { fo:cast($node/node()) }
                </fo:block>
            case element(tei:castGroup) return
                <fo:block space-after="8mm" space-before="8mm">
                    <fo:block font-weight="bold">{$node/tei:head/text()}</fo:block>
                    { fo:cast($node/tei:castItem) }
                </fo:block>
            case element(tei:castItem) return
                <fo:block space-after=".25em">{fo:cast($node/node())}</fo:block>
            case element(tei:role) return
                fo:tei2fo($node/node())
            case element(tei:roleDesc) return
                <fo:inline> (<fo:inline font-style="italic">{$node/text()}</fo:inline>)</fo:inline>
            case element() return
                fo:cast($node/node())
            default return
                $node
};

declare function fo:cast-list($work as element(tei:TEI)) {
    let $cast := $work/tei:text/tei:front/tei:div[@type = "castList"]
    return
        <fo:page-sequence master-reference="Shakespeare">
            <fo:static-content flow-name="kopf">
                <fo:block margin-bottom="0.7mm" text-align="left">
                    <fo:retrieve-marker retrieve-class-name="titel"/>
                </fo:block>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body" font-family="Noto">
                <fo:marker marker-class-name="titel">{$cast/tei:head/text()}</fo:marker>
                <fo:block font-size="30pt" space-after="1em" font-family="Noto">{$cast/tei:head/text()}</fo:block>
                { fo:cast($cast/tei:castList) }
            </fo:flow>
        </fo:page-sequence>
};

declare function fo:main($id as xs:string) {
    let $entry := root(collection($config:data-root)//id($id))//tei:TEI
    return
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" >
            <fo:layout-master-set>
            
                <fo:simple-page-master master-name="Dillmann" margin-top="10mm"
                        margin-bottom="10mm" margin-left="12mm"
                        margin-right="12mm">
                    <fo:region-body column-count="2" column-gap="10mm" margin-top="20mm" margin-left="0mm" margin-right="0mm" margin-bottom="20mm" />
                        <fo:region-before extent="20mm"/>
		<fo:region-after extent="20mm"/>
			
                </fo:simple-page-master>
            </fo:layout-master-set>
            
            <fo:page-sequence master-reference="Dillmann">
                <fo:static-content flow-name="xsl-region-before">
			<fo:block-container height="100%" display-align="center">
				<fo:block text-align="center" font-family="sans-serif" font-size="0.8em"
					> - <fo:page-number/> - </fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="xsl-region-after">
			<fo:block-container>
				<fo:block font-size="0.8em" text-align="right" >
					<fo:basic-link external-destination="http://betamasaheft.aai.uni-hamburg.de/Dillmann/lemma/{$id}">Lexicon Linguae Aethiopicae {fo:footer($entry//tei:form)} | PDF generated form the app on {current-dateTime()} </fo:basic-link>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
                <fo:flow flow-name="xsl-region-body" font-family="Noto" text-align="justify">
                    { fo:tei2fo($entry//tei:text/tei:body/tei:div) }
                </fo:flow>                         
            </fo:page-sequence>
            
        </fo:root>
};



(:fo:main():)
let $id := request:get-parameter("id", ())
let $pdf := xslfo:render(fo:main($id), "application/pdf", (), $local:fop-config)
return
    response:stream-binary($pdf, "media-type=application/pdf", $id || ".pdf")
