<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:http="http://expath.org/ns/http-client" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output encoding="UTF-8" media-type="html"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="refText"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <!--        breaks current showitem function-->
    
    <xsl:template match="text()[parent::t:sense[@xml:lang='la'] or ancestor::t:sense[@xml:lang='la']]">
        
        <!--<xsl:text> </xsl:text>-->
        <xsl:for-each select="tokenize(normalize-space(.), ' ')">
            <xsl:choose>
                <xsl:when test=". = 'Hinc' or . = 'hinc'">
                    <span class="HINC">
                        <xsl:value-of select="."/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="dilEx word">
                        <xsl:value-of select="."/>
                    </span>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="t:sense[@n]">
        <div class="w3-container sense" id="{@xml:id}">
            <b>
                <xsl:choose>
                    
                    <xsl:when test="@n = 'L'">
                        Leslau <br/>
                    </xsl:when>
                    <xsl:when test="@n = 'G'">
                        Grebaut <br/>
                    </xsl:when>
                    <xsl:when test="@n = 'E'">
                        Comparative and etymological data<br/>
                    </xsl:when>
                    <xsl:when test="@n = 'C'">
                        Cross-references <br/>
                    </xsl:when>
                    <xsl:when test="@n = 'X'">
                        Compounds<br/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@n"/>
                        <xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </b>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="t:hi[@rend='sup']">
        <sup>
            <xsl:value-of select="."/>
        </sup>
    </xsl:template>
    
    <xsl:template match="t:lb[@n]">
        <xsl:if test="matches(@n, '[A-Z]')">
            <hr/>
        </xsl:if>
        <xsl:if test="matches(@n, '[A-Z]')">
            <hr/>
        </xsl:if>
        <br/>
        <b>
            <xsl:value-of select="@n"/>
            <xsl:text>)</xsl:text>
        </b>
    </xsl:template>
    
    <xsl:template match="t:lb">        
        <br/>        
    </xsl:template>
    
    <xsl:template match="t:cit[@type='translation']">
        <!--        the space is hardcoded because in some cases for an unanderstood reason the spaces are ignored-->
        <!--        <xsl:text> </xsl:text>-->
        <i>
            <xsl:if test="@xml:lang = 'la'">
                <xsl:attribute name="class">translationLa word</xsl:attribute>
                <xsl:attribute name="lang">la</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="replace(t:quote, '^\s+|\s+$', '')"/>
        </i>
        <sup>
            <a target="_blank" href="/Dillmann/reverse?start=1&amp;lang={@xml:lang}">
                <xsl:value-of select="@xml:lang"/>
            </a>
        </sup>
    </xsl:template>
    
    <xsl:template match="t:cit[@type='transcription']">
        <!--        the space is hardcoded because in some cases for an unanderstood reason the spaces are ignored-->
        <!--        <xsl:text> </xsl:text>-->
        <b>
            <xsl:value-of select="replace(t:quote, '^\s+|\s+$', '')"/>
        </b>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="t:foreign">
        <xsl:text> </xsl:text>
        <span lang="{@xml:lang}" class="word"><xsl:choose>
            <xsl:when test="@xml:lang = 'ar'">
                <xsl:attribute name="dir">rtl</xsl:attribute>
            </xsl:when>
            <xsl:when test="@xml:lang = 'syr'">
                <xsl:attribute name="dir">rtl</xsl:attribute>
            </xsl:when>
            <xsl:when test="@xml:lang = 'he'">
                <xsl:attribute name="dir">rtl</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="dir">ltr</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
            <xsl:value-of select="."/>
            
        </span>
        <xsl:choose>
            <xsl:when test="@xml:lang = 'ar' or @xml:lang = 'syr' or @xml:lang = 'he'">
                <span dir="ltr"/>
            </xsl:when>
            
        </xsl:choose>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    
    <xsl:template match="t:lbl | t:pos | t:case">
        <a>
            <xsl:attribute name="title"><xsl:value-of select="@expand"/></xsl:attribute>
            <xsl:attribute name="class">RefPopup popup</xsl:attribute>
            <xsl:attribute name="data-value"><xsl:value-of select="concat(name(), position())"/></xsl:attribute>
            <span class="popuptext w3-hide w3-tiny w3-padding" id="{concat(name(), position())}">
                <xsl:value-of select="@expand"/>
            </span>
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    <xsl:template match="t:gramGrp">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="t:note">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="t:bibl">
        <a class="Zotero Zotero-citation" data-value="{t:ptr/@target}">
            <xsl:if test="t:citedRange/@unit">
                <xsl:attribute name="data-unit">
                    <xsl:value-of select="t:citedRange/@unit"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="t:citedRange/text()">
                <xsl:attribute name="data-range">
                    <xsl:value-of select="t:citedRange"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </a>
        <!--        <xsl:text> </xsl:text>-->
    </xsl:template>
    
    <xsl:template match="t:ref[not(@type)]">
        <xsl:choose>
            <xsl:when test="@target">
                <xsl:variable name="id" select="substring-after(@target, '#')"/>
                <xsl:variable name="t" select="substring-after(@target, '#c')"/>
                <xsl:choose>
                    <xsl:when test="number($t) ge 1425">
                        <a target="_blank" href="http://www.tau.ac.il/~hacohen/Lexicon/pp{format-number(if(xs:integer($t) mod 2 = 1) then xs:integer($t) else (xs:integer($t)  -1), '#')}.html">
                            <i class="fa fa-cogs" aria-hidden="true"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a target="_blank" href="#" class="internalLink" data-value="{$id}">
                            <xsl:value-of select="$t"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@cRef">
                <xsl:variable name="cRefs">
                    <xsl:value-of select="normalize-space(@cRef)"/>
                </xsl:variable>
                
                <xsl:variable name="ref" select="normalize-space(concat(@cRef, @loc))"/>
                <a>
                    <xsl:attribute name="ref">
                        <xsl:value-of select="$ref"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">RefPopup popup</xsl:attribute>
                    <xsl:attribute name="data-value"><xsl:value-of select="$ref"/></xsl:attribute>
                    <span class="popuptext w3-hide w3-tiny w3-padding" id="{$ref}">
                        <xsl:value-of select="                                 if (doc('xmldb:exist:///db/apps/gez-en/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/dillmanExplanation) then                                     doc('xmldb:exist:///db/apps/gez-en/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/dillmanExplanation/text()                                 else                                     'not able to find explanation in abbreviation list'"/>
                    </span>
                    <xsl:value-of select="@cRef"/>
                    
                    <xsl:choose>
                        <xsl:when test="                                      @cRef = 'Jsp.' or                             @cRef = 'Laur.' or                             @cRef = 'Syn.' or                             @cRef = 'Isenb.'                             ">
                            <xsl:text> p. </xsl:text>
                        </xsl:when>
                        <xsl:when test="                             @cRef = 'Clem.' or                             @cRef = 'Theod.' or                             @cRef = 'Pall.' or                             @cRef = 'Fal.' or                             @cRef = 'Macc.'  or                             @cRef = 'Atq.'  or             @cRef='Chr. L. Atq.' or                @cRef = 'Kid.'     or                             @cRef = 'Cyr.'  or                             @cRef = 'Genz.'  or                             @cRef = 'Ad.'                         ">
                            <xsl:text> f. </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="words" select="tokenize(., '\s+')"/>
                            <xsl:variable name="attributes" select="for $x in @* return if(contains($x, ' ')) then (tokenize($x, ' ')) else ($x)"/>
                            <xsl:variable name="extras">
                                <xsl:value-of select="$words[not(.=$attributes)]"/>
                            </xsl:variable>        
                            <xsl:if test="$extras != ''">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$extras"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@loc"/>
                </a>
                <xsl:choose>
                    <xsl:when test="$refText = 'no'"/>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                        <xsl:if test="doc('xmldb:exist:///db/apps/gez-en/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/bmID/text()">
                            <xsl:variable name="bmID" select="doc('xmldb:exist:///db/apps/gez-en/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/bmID"/>
                            <xsl:variable name="loc" select="                                     if (matches(@loc, '(\d+),\s?(\d+)')) then                                         replace(@loc, ',', '/')                                     else                                         (replace(@loc, ',', '/'))"/>
                            <a class="reference" data-ref="{$ref}" data-bmid="{$bmID}" data-value="{$bmID}/{$loc}">
                                <i class="fa fa-file-text-o" aria-hidden="true"/>
                            </a>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="t:ab">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="t:l">
        <sup>
            <xsl:value-of select="@n"/>
        </sup>
        <xsl:apply-templates/>
        <br/>
    </xsl:template>
    <xsl:template match="t:cb">
        <span class="badge columns">
            <i class="fa fa-columns" aria-hidden="true"/>
            <xsl:text> n. </xsl:text>
            <xsl:value-of select="format-number(@n, '#')"/>
        </span>
    </xsl:template>
    <xsl:template match="t:ref[@target][@type='external']">
        <a class="cleantext" style="text-decoration:none;"><xsl:attribute name="href">
            <xsl:value-of select="@target"/>
        </xsl:attribute><xsl:apply-templates/></a>
    </xsl:template>
    <xsl:template match="t:ref[@target][@type='BM']">
        <a class="MainTitle" data-value="{@target}">
            <xsl:attribute name="href">
                <xsl:value-of select="concat('/',@target)"/>
            </xsl:attribute>
            <xsl:value-of select="@target"/>
        </a>
    </xsl:template>
    
    <xsl:template match="t:ptr">
        <xsl:text> (</xsl:text>
        <a href="{@target}" class="internalRef" data-value="{substring-after(@target, '#')}">
            <xsl:choose>
                <xsl:when test="starts-with(@target, '#D')">Dillmann</xsl:when>
                <xsl:when test="starts-with(@target, '#T')">Traces</xsl:when>
                <xsl:when test="starts-with(@target, '#L')">Leslau</xsl:when>
                <xsl:when test="starts-with(@target, '#G')">Grebaut</xsl:when>
            </xsl:choose>
            <xsl:value-of select="replace(replace(substring-after(@target, '#'), '[DTL]', ''), '(.)', ' $1')"/>
        </a>
        <xsl:text>) </xsl:text>
    </xsl:template>
    
    <xsl:template match="t:subc">
        <b><xsl:value-of select="."/></b>
    </xsl:template>
    
    
</xsl:stylesheet>