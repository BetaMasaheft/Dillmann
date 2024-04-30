xquery version "3.1";

import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
(:import module namespace xqjson = "http://xqilla.sourceforge.net/lib/xqjson";:)
import module namespace http = "http://expath.org/ns/http-client";

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
                        if ($fontsDir) then
                            (
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Cardo-Regular.ttf">
                                <font-triplet
                                    name="Cardo"
                                    style="normal"
                                    weight="normal"/>
                            </font>, <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Cardo-Bold.ttf">
                                <font-triplet
                                    name="Cardo"
                                    style="normal"
                                    weight="700"/>
                            </font>, <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Cardo-Italic.ttf">
                                <font-triplet
                                    name="Cardo"
                                    style="italic"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/coranica_1145.ttf">
                                <font-triplet
                                    name="coranica"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/TitusCBZ.TTF">
                                <font-triplet
                                    name="Titus"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusNormal.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusBold.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusItalic.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="italic"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusBoldItalic.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="italic"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Regular.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Bold.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Italic.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="italic"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-BoldItalic.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="italic"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansEthiopic-Regular.ttf">
                                <font-triplet
                                    name="NotoSansEthiopic"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansEthiopic-Bold.ttf">
                                <font-triplet
                                    name="NotoSansEthiopic"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoNaskhArabic-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoNaskhArabic"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoNaskhArabic-Bold.ttf">
                                
                                <font-triplet
                                    name="NotoNaskhArabic"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansArmenian-Bold.ttf">
                                
                                <font-triplet
                                    name="NotoSansArmenian"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansArmenian-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansArmenian"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansAvestan-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansAvestan"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansCoptic-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansCoptic"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansGeorgian-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansGeorgian"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansHebrew-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansHebrew"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansSyriacEstrangela-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansSyriacEstrangela"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansDevanagari-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansDevanagari"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansDevanagari-bold.ttf">
                                
                                <font-triplet
                                    name="NotoSansDevanagari"
                                    style="normal"
                                    weight="700"/>
                            </font>
                            )
                        else
                            ()
                    }
                </fonts>
            </renderer>
            </renderers>
        </fop>
;


declare function fo:editorKey($key as xs:string){
switch ($key)
                        case "PL" return 'Pietro Maria Liuzzo'
                        case "VP" return 'Vitagrazia Pisani'
                        case "SH" return 'Susanne Hummel'
                        case "MK" return 'Magdalena Krzyżanowska'
                        case "AE" return 'Andreas Ellwardt'
                        case "MB" return 'Maria Bulakh'
                        case "WD" return 'Wolfgang Dickhut'
                        case "JB" return 'Jeremy Brown'
                        case "JF" return 'Joshua Falconer'
                        case "RL" return 'Ralph Lee'
                        case "LB" return 'Leonard Bahr'
                        default return 'Alessandro Bausi'};

declare function fo:lang($lang as xs:string) {
    switch ($lang)
        case 'ar'
            return
                (attribute font-family {'NotoNaskhArabic'}, attribute writing-mode {'rl'})
        case 'he'
            return
                (attribute font-family {'Titus'}, attribute writing-mode {'rl'})
        case 'syr'
            return
                (attribute font-family {'Titus'}, attribute writing-mode {'rl'})
        case 'grc'
            return
                attribute font-family {'Cardo'}
       case 'cop'
            return
                attribute font-family {'Titus'}
        case 'gez'
            return
                (attribute font-family {'Ludolfus'}, attribute letter-spacing {'0.5pt'}, attribute font-size {'0.9em'})
        case 'sa'
            return
                attribute font-family {'NotoSansDevanagari'}
        default return
            attribute font-family {'Ludolfus'}
};

declare function fo:tei2fo($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
        case element(a)
                return
                    <fo:basic-link
                        external-destination="{string($node/@href)}">{$node/text()}</fo:basic-link>
            case element(i)
                return
                    <fo:inline
                        font-style="italic">{fo:tei2fo($node/node())}</fo:inline>
            case element(span)
                return
                    <fo:inline>{if($node/@style[.="font-style:normal;"]) then attribute font-style {'normal'} else ()}{$node/text()}</fo:inline>
            
            case element(tei:TEI) return
                fo:tei2fo($node/tei:text)
            case element(tei:text) return
                fo:tei2fo($node//tei:body)
            case element(tei:div) return
                    <fo:block id="{generate-id($node)}" font-family="Ludolfus">
                        {fo:tei2fo($node/node())}
                    </fo:block>
                    case element(tei:entry) return
                    <fo:block font-family="Ludolfus" font-size="12pt" text-indent="1cm">
                    {fo:tei2fo($node/node())}
                    </fo:block>
            case element(tei:form) return 
            <fo:block font-family="Ludolfus" font-weight="bold" font-size="12pt">
            {$node//text()}
            </fo:block>
            case element(tei:foreign) return 
            <fo:inline > 
            {fo:lang($node/@xml:lang) }
            {$node//text()}
            </fo:inline>  
            case element(tei:cb) return
            <fo:inline >{'{DiL.'|| string($node/@n)||'}'} </fo:inline>
            case element(tei:cit) return
            <fo:inline font-style="italic" >{fo:tei2fo($node/node())} </fo:inline>
            case element(tei:ref) return
            if($node/@type = 'external') then (<fo:basic-link external-destination="{$node/@target}">{fo:tei2fo($node/node())} </fo:basic-link>)
            else if($node/@target) then (<fo:inline >{'{DiL'|| replace($node/@target, '#c', '.') || '}'} </fo:inline>)
            else fo:tei2fo($node/node())
            case element(tei:bibl) return
            <fo:inline >{fo:zoteroCit($node/tei:ptr/@target)}{if($node/tei:citedRange) then ', ' || $node/tei:citedRange/text() else ()}</fo:inline>
             case element(tei:sense) return 
             if($node/@source or $node/@n='L') then
             <fo:block-container margin-top="3mm"> 
             {
 if($node/@source  = '#traces') 
 then (
 <fo:block font-weight="bold" >{(' TraCES ' || string($node/@xml:lang) || ' ')}</fo:block>
 ) 
 else if ($node/@n='L') then <fo:block font-weight="bold">Leslau</fo:block>
  else if ($node/@n='G') then <fo:block font-weight="bold">Grebaut</fo:block>
 else (), <fo:block>{fo:tei2fo($node/node())}</fo:block>}
 </fo:block-container>
 else
(  if ($node/@n='E') then <fo:block font-weight="bold">Comparative and etymological data</fo:block>
    else if ($node/@n='C') then <fo:block font-weight="bold">Cross-references</fo:block> 
      else if ($node/@n='X') then <fo:block font-weight="bold">Compounds</fo:block>
    else if($node/@n) then (<fo:inline font-weight="bold">{string($node/@n) || ')'} </fo:inline>) else (),
                        fo:tei2fo($node/node()))
                  
            case element() return
                fo:tei2fo($node/node())
            default return
                $node
};

declare function fo:Zotero($ZoteroUniqueBMtag as xs:string) {
    let $xml-url := concat('https://api.zotero.org/groups/358366/items?tag=', $ZoteroUniqueBMtag, '&amp;format=bib&amp;locale=en-GB&amp;style=hiob-ludolf-centre-for-ethiopian-studies&amp;linkwrap=1')
   let $req :=
        <http:request
        http-version="1.1"
            href="{xs:anyURI($xml-url)}"
            method="GET">
        </http:request>
   let $data :=  http:send-request($req)[2]
    let $datawithlink := fo:tei2fo($data//div[@class = 'csl-entry'])
    return
        $datawithlink
};

declare function fo:zoteroCit($ZoteroUniqueBMtag as xs:string){
let $xml-url := concat('https://api.zotero.org/groups/358366/items?&amp;tag=', $ZoteroUniqueBMtag, '&amp;include=citation&amp;locale=en-GB&amp;style=hiob-ludolf-centre-for-ethiopian-studies')

let $req :=
        <http:request
        http-version="1.1"
            href="{xs:anyURI($xml-url)}"
            method="GET">
        </http:request>
        
let $zoteroApiResponse := http:send-request($req)[2]
let $decodedzoteroApiResponse := util:base64-decode($zoteroApiResponse)
let $parseedZoteroApiResponse := parse-json($decodedzoteroApiResponse)

return 
replace($parseedZoteroApiResponse?1?citation, '&lt;span&gt;', '') => replace('&lt;/span&gt;', '') 

};

declare function fo:footer($form as element(tei:form)){
<fo:inline font-family="Ludolfus">{$form//text()}</fo:inline>
};



declare function fo:main($id as xs:string) {
    let $entry := root( $config:collection-root//id($id))//tei:TEI
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
					<fo:basic-link external-destination="{$config:appUrl}/Dillmann/lemma/{$id}">Lexicon Linguae Aethiopicae {fo:footer($entry//tei:form)} | PDF generated from the app on {current-dateTime()} </fo:basic-link>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
                <fo:flow flow-name="xsl-region-body" font-family="Ludolfus" text-align="justify">
                    { fo:tei2fo($entry//tei:text/tei:body/tei:div) }
                    <fo:block margin-top="3mm">
                    <fo:block font-weight="bold">Bibliography</fo:block>
                    {for $ptr in distinct-values($entry//tei:bibl/tei:ptr/@target)
                    return
                    <fo:block><fo:inline
                start-indent="5mm" 
                text-indent="-5mm">{fo:Zotero($ptr)}</fo:inline></fo:block>}
                    </fo:block>
                     <fo:block font-size="0.6em" margin-top="3mm">
                     <fo:block font-weight="bold">Revisions</fo:block>
                     <fo:list-block
        provisional-label-separation="1em"
        provisional-distance-between-starts="1em">
{for $change in $entry//tei:change 
let $time := $change/@when
            let $author := fo:editorKey(string($change/@who))
            order by $time descending
            return
                <fo:list-item>
                    <fo:list-item-label
                        end-indent="label-end()"><fo:block>-</fo:block></fo:list-item-label>
                    <fo:list-item-body
                        start-indent="body-start()">
                        <fo:block>
                            {$author || ' '}
                            <fo:inline
                                font-style="italic">
                                {$change/text()}
                            </fo:inline>
                            {' on ' || format-date($time, '[D].[M].[Y]')}
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>}
                </fo:list-block></fo:block>
                </fo:flow>                         
            </fo:page-sequence>
            
        </fo:root>
};



(:fo:main():)
let $id := request:get-parameter("id", ())
let $pdf := xslfo:render(fo:main($id), "application/pdf", (), $local:fop-config)
return
    response:stream-binary($pdf, "media-type=application/pdf", $id || ".pdf")