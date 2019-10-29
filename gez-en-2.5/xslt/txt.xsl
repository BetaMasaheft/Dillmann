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
    <xsl:template match="t:sense">
        <xsl:if test="@source = '#traces'">
            <xsl:text>TraCES (</xsl:text>
            <xsl:value-of select="@xml:lang"/>
            <xsl:text>): </xsl:text>
        </xsl:if>
        <xsl:if test="@n">
            <xsl:value-of select="@n"/>
            <xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="t:foreign">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:ref[not(@type)][not(@target)]">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:ref[@target][not(@type)][not(preceding-sibling::t:lbl[@expand='columna'])]">
        <xsl:value-of select="concat('{DiL.', substring-after(@target, '#c'), '}')"/>
    </xsl:template>
    <xsl:template match="t:ref[@target][not(@type)][preceding-sibling::t:lbl[@expand='columna']]">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="t:cb">
        <xsl:value-of select="concat('{DiL.', @n, '}')"/>
    </xsl:template> 
    <xsl:template match="t:lbl">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:bibl">
        <xsl:if test="t:ptr/@target">
            <xsl:value-of select="t:ptr/@target"/>
        </xsl:if>
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
    <xsl:template match="t:subc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:ref[@type='external'][@target][not(parent::t:bibl)]">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="."/>
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