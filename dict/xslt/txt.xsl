<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:template match="/">
        <xsl:variable name="transformed">
            <xsl:apply-templates select="//t:entry"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($transformed)"/>
    </xsl:template>
    <xsl:template match="t:entry">
        <xsl:value-of select="@xml:id"/>
        <xsl:text>$</xsl:text>
        <xsl:value-of select="t:form/t:foreign/text()"/>
        <xsl:text>$ </xsl:text>
        <xsl:apply-templates select="t:sense"/>
    </xsl:template>
    <xsl:template match="t:cit">
        <xsl:text>&lt;i&gt;</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>&lt;/i&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="t:sense[@xml:lang='la']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="t:foreign">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:ref">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:ref[@target]">
        <xsl:value-of select="concat('{DiL.', substring-after(@target, '#c'), '}')"/>
    </xsl:template>
    <xsl:template match="t:ref[@target][preceding-sibling::t:lbl[@expand='columna']]">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="t:cb">
        <xsl:value-of select="concat('{DiL.', @n, '}')"/>
    </xsl:template> 
    <xsl:template match="t:lbl">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:bibl">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:gramGrp">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:pos">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:case">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
</xsl:stylesheet>