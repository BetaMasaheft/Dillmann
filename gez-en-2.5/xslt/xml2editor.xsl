<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" encoding="UTF-8"/>
    <xsl:template match="/">
            <xsl:variable name="transformed">
           <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($transformed)"/>
    </xsl:template>
  <!--  <xsl:template match="t:entry">
        <xsl:value-of select="@xml:id"/>
        <xsl:text>$</xsl:text>
        <xsl:value-of select="t:form/t:foreign/text()"/>
        <xsl:text>$ </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>-->
    <xsl:template match="t:cit">
        <xsl:text>&gt;</xsl:text>
        <xsl:value-of select="@xml:lang"/>
        <xsl:choose>
            <xsl:when test="@type='translation'">
                <xsl:text>&gt;</xsl:text>
            </xsl:when>
            <xsl:when test="@type='transcription'">
                <xsl:text>!</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="t:quote">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="t:sense">
        <xsl:variable name="sectionName">
            <xsl:choose>
                <xsl:when test="@n">
            <xsl:value-of select="@n"/>
        </xsl:when>
                <xsl:otherwise>
                    <xsl:text>S</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$sectionName"/>
        <xsl:if test="@xml:lang">
            <xsl:value-of select="@xml:lang"/>
        </xsl:if>
        <xsl:text>&lt;</xsl:text>
        
        <xsl:apply-templates/>
        
        <xsl:text>&gt;</xsl:text>
        <xsl:value-of select="$sectionName"/>
        <xsl:text>&gt;</xsl:text>
        
    </xsl:template>
    <xsl:template match="t:foreign">
        <xsl:text>\*</xsl:text>
        <xsl:value-of select="@xml:lang"/>
        <xsl:text>*</xsl:text>
        <xsl:value-of select="normalize-space(.)"/> <xsl:text>\*</xsl:text>
    </xsl:template>
    
    <xsl:template match="t:ref[not(@type)][not(@target)]">
        <xsl:text>*</xsl:text>
        <xsl:value-of select="@cRef"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="@loc"/>
        <xsl:text>*</xsl:text>
        <xsl:variable name="words" select="tokenize(., '\s+')"/>
            <xsl:variable name="attributes" select="for $x in @* return if(contains($x, ' ')) then (tokenize($x, ' ')) else ($x)"/>
        <xsl:variable name="extras">
            <xsl:value-of select="$words[not(.=$attributes)]"/>
        </xsl:variable>        
        <xsl:if test="$extras != ''">
        <xsl:value-of select="$extras"/>
            <xsl:text>|</xsl:text>
        </xsl:if>
        
    </xsl:template>
    <xsl:template match="t:ref[@target][not(@type)]">
        <xsl:value-of select="concat('{DiL.', substring-after(@target, '#c'), '}')"/>
    </xsl:template>
    <!--<xsl:template match="t:ref[@target][not(@type)][preceding-sibling::t:lbl[@expand='columna']]">
        <xsl:value-of select="."/>
    </xsl:template>-->
    <xsl:template match="t:cb">
        <xsl:value-of select="concat('|{DiL.', @n, '}|')"/>
    </xsl:template> 
    <xsl:template match="t:hi[@rend='sup']">
        <xsl:text>ˆ!</xsl:text>
        <xsl:value-of select="."/>
    </xsl:template> 
    <xsl:template match="t:lbl">
        <xsl:text>((</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>))</xsl:text>
    </xsl:template>
    <xsl:template match="t:bibl">
        <xsl:if test="t:citedRange">
            <xsl:text>[</xsl:text>
        <xsl:value-of select="t:citedRange/@unit"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="t:citedRange"/>
        <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:value-of select="t:ptr/@target"/>
<!--        this is for cases in which something is written into the bibl element-->
        <xsl:if test="contains(.,'gramm')">
            <xsl:text>{</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:gramGrp">
        <xsl:text>[[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]]</xsl:text>
    </xsl:template>
    <xsl:template match="t:pos">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>+</xsl:text>
    </xsl:template>
    <xsl:template match="t:case">
        <xsl:text>@</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>@</xsl:text>
    </xsl:template>
    <xsl:template match="t:gen">
        <xsl:text>ˆ</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>ˆ</xsl:text>
    </xsl:template>
    
    <xsl:template match="t:note[t:ref]">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="t:note">
        <xsl:text>!!</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>!!</xsl:text>
    </xsl:template>
    <xsl:template match="t:nd">
        <xsl:text>{ND}</xsl:text>
    </xsl:template>
    <xsl:template match="t:ref[@type='external'][@target][not(parent::t:bibl)]">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)[</xsl:text>
        <xsl:value-of select="@target"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="t:ref[@type='BM'][@target][not(parent::t:bibl)]">
        <xsl:text>(BM)[</xsl:text>
        <xsl:value-of select="@target"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
</xsl:stylesheet>