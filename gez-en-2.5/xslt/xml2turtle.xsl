<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs t" version="2.0"> 
    <!--receives TEI, produces https://www.w3.org/2019/09/lexicog/-->
    <xsl:template match="/">
        <xsl:value-of select="concat( 'dillmann:lexicon lexicog:entry dillmann:',string(//t:entry/@xml:id), ' .')"/> 
    </xsl:template> 
</xsl:stylesheet>
