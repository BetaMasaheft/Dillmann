<?xml version="1.0" encoding="UTF-8"?>
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
        <span class="dilEx">
                <xsl:value-of select="."/>
            </span>
            <xsl:text> </xsl:text>
    </xsl:for-each>
</xsl:template>
    
    <xsl:template match="t:sense[@n]">
        <div class="col-md-12">
            <b>
                <xsl:value-of select="@n"/>
                <xsl:text>)</xsl:text>
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
    
    
    <xsl:template match="t:cit[@type='translation']">
        <!--        the space is hardcoded because in some cases for an unanderstood reason the spaces are ignored-->
        <xsl:text> </xsl:text>
        <i>
            <xsl:if test="@xml:lang = 'la'">
                <xsl:attribute name="class">translationLa</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </i>
    </xsl:template>
    
    <xsl:template match="t:cit[@type='transcription']">
        <!--        the space is hardcoded because in some cases for an unanderstood reason the spaces are ignored-->
        <xsl:text> </xsl:text>
        <b>
            <xsl:value-of select="."/>
        </b>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="t:foreign">
        <xsl:text> </xsl:text>
        <span lang="{@xml:lang}">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="t:lbl | t:pos | t:case">
        <a>
            <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
            <xsl:attribute name="data-title">
                <xsl:value-of select="@expand"/>
            </xsl:attribute>
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
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="t:ref">
        <xsl:choose>
            <xsl:when test="@target">
                <xsl:variable name="id" select="substring-after(@target, '#')"/>
                <xsl:variable name="t" select="substring-after(@target, '#c')"/>
                <a href="#" class="internalLink" data-value="{$id}">
                    <xsl:if test="number($t) &gt;= 1425">A&amp;E: </xsl:if>
                    <xsl:value-of select="$t"/>
                </a>
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
                    <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="                                 if (doc('xmldb:exist:///db/apps/dict/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/dillmanExplanation) then                                     doc('xmldb:exist:///db/apps/dict/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/dillmanExplanation/text()                                 else                                     'not able to find explanation in abbreviation list'"/>
                    </xsl:attribute>
                    <xsl:value-of select="@cRef"/>
                    <xsl:choose>
                        <xsl:when test="                             @cRef = 'Kuf.' or                             @cRef = 'Jsp.' or                             @cRef = 'Laur.' or                             @cRef = 'Syn.' or                             @cRef = 'Isenb.'                             ">
                            <xsl:text> p. </xsl:text>
                        </xsl:when>
                        <xsl:when test="                             @cRef = 'Clem.' or                             @cRef = 'Theod.' or                             @cRef = 'Pall.' or                             @cRef = 'Fal.' or                             @cRef = 'Macc.'  or                             @cRef = 'Atq.'  or                             @cRef = 'Kid.'     or                             @cRef = 'Cyr.'  or                             @cRef = 'Genz.'  or                             @cRef = 'Ad.'                         ">
                            <xsl:text> f. </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@loc"/>
                </a>
                <xsl:choose>
                    <xsl:when test="$refText = 'no'"/>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                        <xsl:if test="doc('xmldb:exist:///db/apps/dict/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/bmID/text()">
                            <xsl:variable name="bmID" select="doc('xmldb:exist:///db/apps/dict/abbreviaturen.xml')//abbreviatur[reference[. = $cRefs]]/bmID"/>
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

</xsl:stylesheet>