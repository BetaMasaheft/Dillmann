xquery version "3.1";

declare namespace fo = "http://www.w3.org/1999/XSL/Format";
declare namespace xslfo = "http://exist-db.org/xquery/xslfo";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace file = "http://exist-db.org/xquery/file";

import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace xqjson = "http://xqilla.sourceforge.net/lib/xqjson";
import module namespace http = "http://expath.org/ns/http-client";

declare variable $local:fop-config := let $fontsDir := config:get-fonts-dir()
return <fop version="1.0">
    <strict-configuration>true</strict-configuration>
    <strict-validation>false</strict-validation>
    <base>./</base>
    <renderers>
      <renderer mime="application/pdf">
        <fonts>
          {
            if ($fontsDir) then (
              <font
                embed-url="file:{ $fontsDir }/Cardo-Regular.ttf"
                kerning="yes"
              >
                <font-triplet name="Cardo" style="normal" weight="normal" />
              </font>,
              <font embed-url="file:{ $fontsDir }/Cardo-Bold.ttf" kerning="yes">
                <font-triplet name="Cardo" style="normal" weight="700" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/Cardo-Italic.ttf"
                kerning="yes"
              >
                <font-triplet name="Cardo" style="italic" weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/coranica_1145.ttf"
                kerning="yes"
              >
                <font-triplet name="coranica" style="normal" weight="normal" />
              </font>,
              <font embed-url="file:{ $fontsDir }/TitusCBZ.TTF" kerning="yes">
                <font-triplet name="Titus" style="normal" weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/LudolfusNormal.ttf"
                kerning="yes"
              >
                <font-triplet name="Ludolfus" style="normal" weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/LudolfusBold.ttf"
                kerning="yes"
              >
                <font-triplet name="Ludolfus" style="normal" weight="700" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/LudolfusItalic.ttf"
                kerning="yes"
              >
                <font-triplet name="Ludolfus" style="italic" weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/LudolfusBoldItalic.ttf"
                kerning="yes"
              >
                <font-triplet name="Ludolfus" style="italic" weight="700" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSans-Regular.ttf"
                kerning="yes"
              >
                <font-triplet name="Noto" style="normal" weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSans-Bold.ttf"
                kerning="yes"
              ><font-triplet name="Noto" style="normal" weight="700" /></font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSans-Italic.ttf"
                kerning="yes"
              >
                <font-triplet name="Noto" style="italic" weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSans-BoldItalic.ttf"
                kerning="yes"
              ><font-triplet name="Noto" style="italic" weight="700" /></font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansEthiopic-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansEthiopic"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansEthiopic-Bold.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansEthiopic"
                  style="normal"
                  weight="700" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoNaskhArabic-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoNaskhArabic"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoNaskhArabic-Bold.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoNaskhArabic"
                  style="normal"
                  weight="700" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansArmenian-Bold.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansArmenian"
                  style="normal"
                  weight="700" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansArmenian-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansArmenian"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansAvestan-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansAvestan"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansCoptic-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansCoptic"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansGeorgian-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansGeorgian"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansHebrew-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansHebrew"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{
                  $fontsDir
                }/NotoSansSyriacEstrangela-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansSyriacEstrangela"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansDevanagari-Regular.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansDevanagari"
                  style="normal"
                  weight="normal" />
              </font>,
              <font
                embed-url="file:{ $fontsDir }/NotoSansDevanagari-bold.ttf"
                kerning="yes"
              >
                <font-triplet
                  name="NotoSansDevanagari"
                  style="normal"
                  weight="700" />
              </font>
            ) else (
            )
          }
        </fonts>
      </renderer>
    </renderers>
  </fop>;

declare function fo:editorKey ($key as xs:string) {
  switch ($key)
    case "PL" return
      "Pietro Maria Liuzzo"
    case "VP" return
      "Vitagrazia Pisani"
    case "SH" return
      "Susanne Hummel"
    case "MK" return
      "Magdalena Krzyzanowska"
    case "AE" return
      "Andreas Ellwardt"
    case "MB" return
      "Maria Bulakh"
    case "WD" return
      "Wolfgang Dickhut"
    case "JB" return
      "Jeremy Brown"
    case "JF" return
      "Joshua Falconer"
    case "RL" return
      "Ralph Lee"
    default return
      "Alessandro Bausi"
};

declare function fo:lang ($lang as xs:string) {
  switch ($lang)
    case "ar" return
      (attribute font-family { "coranica" }, attribute writing-mode { "rl" })
    case "he" return
      (attribute font-family { "Titus" }, attribute writing-mode { "rl" })
    case "syr" return
      (attribute font-family { "Titus" }, attribute writing-mode { "rl" })
    case "grc" return
      attribute font-family { "Cardo" }
    case "cop" return
      attribute font-family { "Titus" }
    case "gez" return
      (
        attribute font-family { "Ludolfus" },
        attribute letter-spacing { "0.5pt" },
        attribute font-size { "0.9em" }
      )
    case "sa" return
      attribute font-family { "NotoSansDevanagari" }
    default return
      attribute font-family { "Ludolfus" }
};

declare function fo:tei2fo ($nodes as node()*) {
  for $node in $nodes
  return typeswitch ($node)
      case element(a) return
        <fo:basic-link external-destination="{ string($node/@href) }">
          { $node/text() }
        </fo:basic-link>
      case element(i) return
        <fo:inline font-style="italic">{ $node/text() }</fo:inline>
      case element(span) return
        <fo:inline>{ $node/text() }</fo:inline>
      case element(tei:TEI) return
        fo:tei2fo($node/tei:text)
      case element(tei:text) return
        fo:tei2fo($node//tei:body)
      case element(tei:div) return
        <fo:block font-family="Noto" id="{ generate-id($node) }">
          { fo:tei2fo($node/node()) }
        </fo:block>
      case element(tei:entry) return
        <fo:block font-family="Noto" font-size="12pt" text-indent="1cm">
          { fo:tei2fo($node/node()) }
        </fo:block>
      case element(tei:form) return
        <fo:inline font-family="Ludolfus" font-size="12pt" font-weight="bold">
          { $node//text() }
        </fo:inline>
      case element(tei:foreign) return
        <fo:inline>{ fo:lang($node/@xml:lang) }{ $node//text() }</fo:inline>
      case element(tei:cb) return
        <fo:inline id="{ string($node/@xml:id) }">
          { "{DiL." || string($node/@n) || "}" }
        </fo:inline>
      case element(tei:cit) return
        <fo:inline font-style="italic">{ fo:tei2fo($node/node()) }</fo:inline>
      case element(tei:ref) return
        if ($node/@target) then (
          <fo:inline>
            {
              "{DiL" || replace($node/@target, "#c", ".") || "}"
            } [↗<fo:page-number-citation
              ref-id="{ replace($node/@target, "#", "") }" />]</fo:inline>
        ) else
          fo:tei2fo($node/node())
      case element(tei:bibl) return
        <fo:inline>
          { fo:zoteroCit($node/tei:ptr/@target) }
          {
            " " ||
              $node/tei:citedRange/@unit ||
              " " ||
              $node/tei:citedRange/text()
          }
        </fo:inline>
      case element(tei:sense) return
        (
          if ($node/@source = "#traces") then (
            <fo:inline font-weight="bold">
              { (" TraCES " || string($node/@xml:lang) || " ") }
            </fo:inline>
          ) else (
          ),
          if ($node/@n) then (
            <fo:inline font-weight="bold">
              { string($node/@n) || ")" }
            </fo:inline>
          ) else (
          ),
          fo:tei2fo($node/node())
        )
      case element() return
        fo:tei2fo($node/node())

      default return
        $node
};

declare function fo:Zotero ($ZoteroUniqueBMtag as xs:string) {
  let $xml-url := concat(
    "https://api.zotero.org/groups/358366/items?tag=",
    $ZoteroUniqueBMtag,
    "&amp;format=bib&amp;style=hiob-ludolf-centre-for-ethiopian-studies&amp;linkwrap=1"
  )
  let $data := httpclient:get(xs:anyURI($xml-url), true(), <Headers />)
  let $datawithlink := fo:tei2fo($data//div[@class = "csl-entry"])
  return $datawithlink
};

declare function fo:zoteroCit ($ZoteroUniqueBMtag as xs:string) {
  let $xml-url := concat(
    "https://api.zotero.org/groups/358366/items?&amp;tag=",
    $ZoteroUniqueBMtag,
    "&amp;include=citation&amp;style=hiob-ludolf-centre-for-ethiopian-studies"
  )

  let $req := <http:request
    href="{ xs:anyURI($xml-url) }"
    http-version="1.1"
    method="GET" />

  let $zoteroApiResponse := http:send-request($req)[2]
  let $decodedzoteroApiResponse := util:base64-decode($zoteroApiResponse)
  let $parseedZoteroApiResponse := xqjson:parse-json($decodedzoteroApiResponse)

  return replace(
      $parseedZoteroApiResponse//*:pair[@name = "citation"]/text(),
      "&lt;span&gt;",
      ""
    )
      => replace("&lt;/span&gt;", "")
};

declare function fo:footer ($form as element(tei:form)) {
  <fo:inline font-family="Ludolfus">{ $form//text() }</fo:inline>
};

declare function fo:main () {
  <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <fo:layout-master-set>
      <fo:simple-page-master
        margin-bottom="20mm"
        margin-left="20mm"
        margin-right="20mm"
        margin-top="20mm"
        master-name="BM"
      >
        <fo:region-body
          margin-bottom="20mm"
          margin-left="0mm"
          margin-right="0mm"
          margin-top="20mm" />
        <fo:region-before extent="20mm" />
        <fo:region-after extent="20mm" />
      </fo:simple-page-master>
      <fo:simple-page-master
        margin-bottom="10mm"
        margin-left="12mm"
        margin-right="12mm"
        margin-top="10mm"
        master-name="Dillmann"
      >
        <fo:region-body
          column-count="2"
          column-gap="10mm"
          margin-bottom="20mm"
          margin-left="0mm"
          margin-right="0mm"
          margin-top="20mm" />
        <fo:region-before extent="20mm" />
        <fo:region-after extent="20mm" />
      </fo:simple-page-master>
    </fo:layout-master-set>
    { fo:titlepage() }
    <fo:page-sequence master-reference="Dillmann">
      <fo:static-content flow-name="xsl-region-before">
        <fo:block-container display-align="center" height="100%">
          <fo:block
            font-family="sans-serif"
            font-size="0.8em"
            text-align="center"
          > - <fo:page-number /> - </fo:block>
        </fo:block-container>
      </fo:static-content>
      <fo:static-content flow-name="xsl-region-after">
        <fo:block-container>
          <fo:block font-size="0.8em" text-align="right">
            <fo:basic-link
              external-destination="{ $config:appUrl }/Dillmann/"
            >Lexicon Linguae Aethiopicae </fo:basic-link>
          </fo:block>
        </fo:block-container>
      </fo:static-content>
      <fo:flow
        flow-name="xsl-region-body"
        font-family="Ludolfus"
        text-align="justify"
      >
        {
          for $entry in subsequence($config:collection-root//tei:entry, 1, 500)
          let $changes := root($entry)//tei:change
          order by $entry/@n

          return <fo:block margin-top="5mm">
              {
                if ($entry//tei:rs[@type = "root"]) then (
                  <fo:leader
                    leader-length="80%"
                    leader-pattern="rule"
                    rule-style="solid"
                    rule-thickness="2pt" />
                ) else (
                )
              }
              <fo:block>{ fo:tei2fo($entry/node()) }</fo:block>
            </fo:block>
        }
        <fo:block margin-top="3mm">
          <fo:block font-weight="bold">Bibliography</fo:block>
          {
            for $ptr in
              distinct-values($config:collection-root//tei:bibl/tei:ptr/@target)
            return <fo:block>
                <fo:inline start-indent="5mm" text-indent="-5mm">
                  { fo:Zotero($ptr) }
                </fo:inline>
              </fo:block>
          }
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
  </fo:root>
};

declare function fo:titlepage () {
  <fo:page-sequence master-reference="BM">
    <fo:flow flow-name="xsl-region-body" font-family="Ludolfus">
      <fo:block
        font-size="44pt"
        text-align="center"
      >
                Lexicon Linguae Aethiopicae</fo:block>
      <fo:block
        font-size="20pt"
        font-style="italic"
        space-after="2em"
        space-before="2em"
        text-align="center"
      >
                edited by
            </fo:block>
      <fo:block
        font-size="20pt"
        font-style="italic"
        space-after="2em"
        space-before="2em"
        text-align="center"
      >
                Augustus Dillmann, Alessandro Bausi, Andreas Ellwardt, Wolfgang Dickhut, Susanne Hummel and Vitagrazia Pisani 
            </fo:block>
      <fo:block
        font-size="20pt"
        font-style="italic"
        space-after="2em"
        space-before="2em"
        text-align="center"
      >
               TraCES project
            </fo:block>
    </fo:flow>
  </fo:page-sequence>
};

let $pdf := xslfo:render(fo:main(), "application/pdf", (), $local:fop-config)
return response:stream-binary(
    $pdf,
    "media-type=application/pdf",
    "DillmannAll.pdf"
  )
