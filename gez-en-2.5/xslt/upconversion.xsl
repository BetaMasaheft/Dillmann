<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <xsl:param name="source"/>
    <!--    in the first step the main meaning are matched in the string searching <1<, <A< or any other and the corresponding closing notation-->
    <xsl:template match="/">
        <xsl:analyze-string regex="(&lt;S)((\w{{2,3}})?(&lt;))(([a-z0-9αβγδεζηθιλκμνξοπρστ])\))?(.*)(&gt;S&gt;)" select="normalize-space(.)" flags="s">
            <xsl:matching-substring>
                <xsl:variable name="all" select="regex-group(7)"/>
                <!--                if there is a match, a sense element is constructed and sense2 is called to look for other nested meanings-->
                <sense>
                    <xsl:if test="regex-group(3)">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="source">
                        <xsl:value-of select="concat('#', $source)"/>
                    </xsl:attribute>
                    <xsl:if test="regex-group(5)">
                        <xsl:attribute name="n">
                            <xsl:value-of select="regex-group(6)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="sense2">
                        <xsl:with-param name="sense2" select="$all"/>
                    </xsl:call-template>
                </sense>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="all" select="."/>
                <xsl:call-template name="gramGrp">
                    <xsl:with-param name="all" select="$all"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="sense2">
        <xsl:param name="sense2"/>
        <xsl:analyze-string regex="(&lt;([A-Za-z\dαβγδεζηθιλκμνξοπρστ]))((\w{{2,3}})?(&lt;))(.*?)(&gt;\2&gt;)" select="$sense2" flags="s">
            <xsl:matching-substring>
                <xsl:variable name="all" select="regex-group(6)"/>
                <sense>
                    <xsl:if test="matches(regex-group(3), '\w\w\w?')">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="regex-group(2)">
                        <xsl:attribute name="n">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="sense3">
                        <xsl:with-param name="sense3" select="$all"/>
                    </xsl:call-template>
                </sense>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="all" select="."/>
                <xsl:call-template name="gramGrp">
                    <xsl:with-param name="all" select="$all"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="sense3">
        <xsl:param name="sense3"/>
        <!--        <sense><xsl:value-of select="$sense2"/></sense>-->
        <xsl:analyze-string regex="(&lt;([A-Za-z\dαβγδεζηθιλκμνξοπρστ]))((\w{{2,3}})?(&lt;))(.*?)(&gt;\2&gt;)" select="$sense3" flags="s">
            <xsl:matching-substring>
                <xsl:variable name="all" select="regex-group(6)"/>
                <sense>
                    <xsl:if test="matches(regex-group(3), '\w\w\w?')">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="regex-group(2)">
                        <xsl:attribute name="n">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="sense4">
                        <xsl:with-param name="sense4" select="$all"/>
                    </xsl:call-template>
                </sense>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="all" select="."/>
                <xsl:call-template name="gramGrp">
                    <xsl:with-param name="all" select="$all"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:template name="sense4">
        <xsl:param name="sense4"/>
        <!--        <sense><xsl:value-of select="$sense2"/></sense>-->
        <xsl:analyze-string regex="(&lt;([a-z\dαβγδεζηθιλκμνξοπρστ]))((\w{{2,3}})?(&lt;))(.*?)(&gt;\2&gt;)" select="$sense4" flags="s">
            <xsl:matching-substring>
                <xsl:variable name="all" select="regex-group(6)"/>
                <sense>
                    <xsl:if test="matches(regex-group(3), '\w\w\w?')">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="regex-group(2)">
                        <xsl:attribute name="n">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="sense5">
                        <xsl:with-param name="sense5" select="$all"/>
                    </xsl:call-template>
                </sense>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="all" select="."/>
                <xsl:call-template name="gramGrp">
                    <xsl:with-param name="all" select="$all"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:template name="sense5">
        <xsl:param name="sense5"/>
        <!--        <sense><xsl:value-of select="$sense2"/></sense>-->
        <xsl:analyze-string regex="(&lt;([a-z\dαβγδεζηθιλκμνξοπρστ]))((\w{{2,3}})?(&lt;))(.*?)(&gt;\2&gt;)" select="$sense5" flags="s">
            <xsl:matching-substring>
                <xsl:variable name="all" select="regex-group(6)"/>
                <sense>
                    <xsl:if test="matches(regex-group(3), '\w\w\w?')">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="regex-group(2)">
                        <xsl:attribute name="n">
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="gramGrp">
                        <xsl:with-param name="all" select="$all"/>
                    </xsl:call-template>
                </sense>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="all" select="."/>
                <xsl:call-template name="gramGrp">
                    <xsl:with-param name="all" select="$all"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>




    <xsl:template name="gramGrp">
        <xsl:param name="all"/>
        <xsl:analyze-string regex="(\[\[)(.*?)(\]\])" select="$all">
            <xsl:matching-substring>
                <xsl:variable name="text" select="regex-group(2)"/>
                <gramGrp>
                    <xsl:call-template name="lbl">
                        <xsl:with-param name="text1" select="$text"/>
                    </xsl:call-template>
                </gramGrp>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text" select="."/>
                <xsl:call-template name="cit">
                    <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="cit">
        <xsl:param name="text"/>
        <xsl:analyze-string regex="(&gt;)(\w{{2,3}})(&gt;)((.*?)&gt;)" select="$text">
            <xsl:matching-substring>
                <cit type="translation" xml:lang="{regex-group(2)}">
                    <quote>
                        <xsl:value-of select="regex-group(5)"/>
                    </quote>
                </cit>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text1" select="."/>
                <xsl:call-template name="transcription">
                    <xsl:with-param name="text1" select="$text1"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="transcription">
        <xsl:param name="text1"/>
        <xsl:analyze-string regex="((&gt;)(\w{{2,3}}))((!)(.*?)(&gt;))" select="$text1">
            <xsl:matching-substring>
                <cit type="transcription" xml:lang="{regex-group(3)}">
                    <quote>
                        <xsl:value-of select="regex-group(6)"/>
                    </quote>
                </cit>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text2" select="."/>
                <xsl:call-template name="lbl">
                    <xsl:with-param name="text2" select="$text2"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <!--lbl-->
    <xsl:template name="lbl">
        <xsl:param name="text1"/>
        <xsl:param name="text2"/>
        <xsl:variable name="t">
            <xsl:choose>
                <xsl:when test="$text1">
                    <xsl:value-of select="$text1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$text2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:analyze-string regex="\(\(([a-zA-Z\.,\s]*?)\)\)" select="$t">
            <xsl:matching-substring>
                <xsl:variable name="string">
                    <xsl:choose>
                        <xsl:when test="regex-group(1) = 'vid.'">videas</xsl:when>
                        <xsl:when test="regex-group(1) = 'vid. sub'">videas</xsl:when>
                        <xsl:when test="regex-group(1) = 'vid. sub.'">videas</xsl:when>
                        <xsl:when test="regex-group(1) = 'id.q.'">idem quod</xsl:when>
                        <xsl:when test="regex-group(1) = 'i.q.'">idem quod</xsl:when>
                        <xsl:when test="regex-group(1) = 's. fin.'">sub finem</xsl:when>
                        <xsl:when test="regex-group(1) = 'radd.'">radices</xsl:when>
                        <xsl:when test="regex-group(1) = 'Radd.'">radices</xsl:when>
                        <xsl:when test="regex-group(1) = 'vic.'">vicinus</xsl:when>
                        <xsl:when test="regex-group(1) = 'Vic.'">vicinus</xsl:when>
                        <xsl:when test="regex-group(1) = 'var.'">varia lectio</xsl:when>
                        <xsl:when test="regex-group(1) = 'pers.'">persona</xsl:when>
                        <xsl:when test="regex-group(1) = 'inus.'">inusitatus</xsl:when>
                        <xsl:when test="regex-group(1) = 'vers. nov.'">versio nova</xsl:when>
                        <xsl:when test="regex-group(1) = 'coll.'">collatio, -is vel collectivum,
                            -e</xsl:when>
                        <xsl:when test="regex-group(1) = 'cfr.'">conferas</xsl:when>
                        <xsl:when test="regex-group(1) = 'vers. ant.'">versio antiqua</xsl:when>
                        <xsl:when test="regex-group(1) = 'Sing.'">Singularis</xsl:when>
                        <xsl:when test="regex-group(1) = 'Form. Conf.'">Formula
                            Confessionis</xsl:when>
                        <xsl:when test="regex-group(1) = 'vers. alt.'">versio altera</xsl:when>
                        <xsl:when test="regex-group(1) = 'c.c.'">construitur cum</xsl:when>
                        <xsl:when test="regex-group(1) = 'c.'">cum</xsl:when>
                        <xsl:when test="regex-group(1) = 'Abb.'">d'Abbadie</xsl:when>
                        <xsl:when test="regex-group(1) = 'ed.'">edidit</xsl:when>
                        <xsl:when test="regex-group(1) = 'Vers. Lat.'">Versio Latina Jubilaeorum
                            libri, exstat in libro: Monumenta sacra et profana e codicibus Bibl.
                            Ambrosianae tom. I, fasc. I. ed Ceriani, Mediol. 1861. 4°.</xsl:when>
                        <xsl:when test="regex-group(1) = 'id.'">idem</xsl:when>
                        <xsl:when test="regex-group(1) = 'st. c.'">status constructus</xsl:when>
                        <xsl:when test="regex-group(1) = 'dupl.'">duplex</xsl:when>
                        <xsl:when test="regex-group(1) = 'rad.'">radix</xsl:when>
                        <xsl:when test="regex-group(1) = 'vid.'">videas</xsl:when>
                        <xsl:when test="regex-group(1) = 'Vid.'">videas</xsl:when>
                        <xsl:when test="regex-group(1) = 'sc.'">scilicet</xsl:when>
                        <xsl:when test="regex-group(1) = 'sec.'">secundum</xsl:when>
                        <xsl:when test="regex-group(1) = 'obsc.'">obscoene</xsl:when>
                        <xsl:when test="regex-group(1) = 'seq.'">sequens</xsl:when>
                        <xsl:when test="regex-group(1) = 'ann.'">annotatio</xsl:when>
                        <xsl:when test="regex-group(1) = 'transl.'">translate</xsl:when>
                        <xsl:when test="regex-group(1) = 'lex.'">lexicon</xsl:when>
                        <xsl:when test="regex-group(1) = 'col.'">columna</xsl:when>
                        <xsl:when test="regex-group(1) = 'opp.'">oppositum, -o, -nitur</xsl:when>
                        <xsl:when test="regex-group(1) = 'Pl.'">pluralis</xsl:when>
                        <xsl:when test="regex-group(1) = 'q.v.'">quod videas</xsl:when>
                        <xsl:when test="regex-group(1) = 'concr.'">concretus, e (opp.
                            abstracto)</xsl:when>
                        <xsl:when test="regex-group(1) = 'ib.'">ibidem</xsl:when>
                        <xsl:when test="regex-group(1) = 'N.T.'">Novum Testamentum</xsl:when>
                        <xsl:when test="regex-group(1) = 'rom.'">romanae editionis</xsl:when>
                        <xsl:when test="regex-group(1) = 'auct.'">auctore, auctoritate</xsl:when>
                        <xsl:when test="regex-group(1) = 'e.q.'">eadem quae</xsl:when>
                        <xsl:when test="regex-group(1) = 'Epil.'">Epilogus</xsl:when>
                        <xsl:when test="regex-group(1) = 'ex. gr.'">exempli gratia</xsl:when>
                        <xsl:otherwise>not found</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <lbl>
                    <xsl:attribute name="expand">
                        <xsl:value-of select="$string"/>
                    </xsl:attribute>
                    <xsl:value-of select="regex-group(1)"/>
                </lbl>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text3" select="."/>
                <xsl:call-template name="foreign">
                    <xsl:with-param name="text3" select="$text3"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="foreign">
        <xsl:param name="text3"/>
        <xsl:analyze-string regex="(\\\*)(.*?)(\*)(.*?)(\\\*)" select="$text3">
            <xsl:matching-substring>
                <foreign>
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:attribute>
                    <xsl:value-of select="regex-group(4)"/>
                </foreign>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable select="." name="text4"/>
                <xsl:call-template name="PoS">
                    <xsl:with-param name="text4" select="$text4"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="PoS">
        <xsl:param name="text4"/>
        <xsl:analyze-string regex="\+(.*?)\+" select="$text4">
            <xsl:matching-substring>
                <xsl:variable name="string">
                    <xsl:choose>
                        <xsl:when test="regex-group(1) = 'abstr.'">abstractum, -e</xsl:when>
                        <xsl:when test="regex-group(1) = 'adv.'">adverbium, adverbialiter</xsl:when>
                        <xsl:when test="regex-group(1) = 'refl. Refl.'">reflexivum</xsl:when>
                        <xsl:when test="regex-group(1) = 'Infin. nom.'">infinitivus nominalis,
                            nominascens</xsl:when>
                        <xsl:when test="regex-group(1) = 'peregr. n.'">nomen peregrinum</xsl:when>
                        <xsl:when test="regex-group(1) = 'Impf.'">imperfectum</xsl:when>
                        <xsl:when test="regex-group(1) = 'Subst.'">Substantivum</xsl:when>
                        <xsl:when test="regex-group(1) = 'Infin. verb.'">infinitivus
                            verbalis</xsl:when>
                        <xsl:when test="regex-group(1) = 'praep.'">praepositio</xsl:when>
                        <xsl:when test="regex-group(1) = 'pron. suff.'">pronomen suffixum</xsl:when>
                        <xsl:when test="regex-group(1) = 'pron.'">pronomen</xsl:when>
                        <xsl:when test="regex-group(1) = 'Pron.'">pronomen</xsl:when>
                        <xsl:when test="regex-group(1) = 'Subj.'">Subjunctivus</xsl:when>
                        <xsl:when test="regex-group(1) = 'part.'">participium</xsl:when>
                        <xsl:when test="regex-group(1) = 'n. act.'">nomen actionis</xsl:when>
                        <xsl:when test="regex-group(1) = 'n. pr.'">nomen proprium</xsl:when>
                        <xsl:when test="regex-group(1) = 'n. ag. n.ag.'">nomen agentis</xsl:when>
                        <xsl:when test="regex-group(1) = 'n. nom.'">nomen</xsl:when>
                        <xsl:when test="regex-group(1) = 'pass.'">passivum</xsl:when>
                        <xsl:when test="regex-group(1) = 'adj.'">adjectivum</xsl:when>
                        <xsl:when test="regex-group(1) = 'absol. abs.'">absolute</xsl:when>
                        <xsl:when test="regex-group(1) = 'num.'">numerale</xsl:when>
                        <xsl:when test="regex-group(1) = 'denom.'">denominates</xsl:when>
                        <xsl:when test="regex-group(1) = 'conj.'">conjunctio</xsl:when>
                        <xsl:when test="regex-group(1) = 'rel.'">relativum</xsl:when>
                        <xsl:otherwise>not found</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <pos>
                    <xsl:attribute name="expand">
                        <xsl:value-of select="$string"/>
                    </xsl:attribute>
                    <xsl:value-of select="regex-group(1)"/>
                </pos>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text5" select="."/>
                <xsl:call-template name="ref">
                    <xsl:with-param name="text5" select="$text5"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="ref">
        <xsl:param name="text5"/>
        <xsl:analyze-string regex="(\*(.*?))(\|(.*?)\*)(([a-z\.,\s]+)\|)?" select="$text5">
            <xsl:matching-substring>
                <ref>
                    <xsl:attribute name="cRef">
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:attribute>
                    <xsl:attribute name="loc">
                        <xsl:value-of select="regex-group(4)"/>
                    </xsl:attribute>
                    <xsl:variable name="unit">
                        <xsl:if test="regex-group(5)">
                            <xsl:value-of select="concat(' ', regex-group(6))"/>

                        </xsl:if>
                    </xsl:variable>
                    <xsl:value-of select="concat(regex-group(2), $unit, ' ', regex-group(4))"/>
                </ref>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text6" select="."/>
                <xsl:call-template name="bibl">
                    <xsl:with-param name="text6" select="$text6"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:template name="bibl">
        <xsl:param name="text6"/>
        <xsl:analyze-string regex="(\[(.*?)\])?(bm:(\w+))(\{{(.*?)\}})?" select="$text6">
            <xsl:matching-substring>
                <bibl>
                    <ptr>
                        <xsl:attribute name="target">
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:attribute>
                    </ptr>
                    <xsl:if test="regex-group(5)">
                        <xsl:value-of select="regex-group(6)"/>
                    </xsl:if>
                    <xsl:if test="regex-group(1)">
                        <citedRange>
                            <xsl:variable name="unit" select="substring-before(regex-group(2), ',')"/>
                            <xsl:choose>
                                <xsl:when test="contains($unit, '§')">
                                    <xsl:attribute name="unit">paragraph</xsl:attribute>
                                </xsl:when>
                                <xsl:when test="contains($unit, 'p.') or contains($unit, 's.')">
                                    <xsl:attribute name="unit">page</xsl:attribute>
                                </xsl:when>
                                <xsl:when test="contains($unit, 'n.')">
                                    <xsl:attribute name="unit">item</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="unit">
                                        <xsl:value-of select="$unit"/>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="substring-after(regex-group(2), ',')"/>
                        </citedRange>
                    </xsl:if>
                </bibl>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text7" select="."/>
                <xsl:call-template name="DilCb">
                    <xsl:with-param name="text7" select="$text7"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:template name="DilCb">
        <xsl:param name="text7"/>
        <xsl:analyze-string regex="(\|\{{DiL\.(.*?)\}}\|)" select="$text7">
            <xsl:matching-substring>
                <cb>
                    <xsl:attribute name="n">
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat('c', regex-group(2))"/>
                    </xsl:attribute>
                </cb>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text8" select="."/>
                <xsl:call-template name="refInt">
                    <xsl:with-param name="text8" select="$text8"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="refInt">
        <xsl:param name="text8"/>
        <xsl:analyze-string regex="(\{{DiL\.(.*?)\}})" select="$text8">
            <xsl:matching-substring>
                <ref>
                    <xsl:attribute name="target">
                        <xsl:value-of select="concat('#c', regex-group(2))"/>
                    </xsl:attribute>
                </ref>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text9" select="."/>
                <xsl:call-template name="case">
                    <xsl:with-param name="text9" select="$text9"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="case">
        <xsl:param name="text9"/>
        <xsl:analyze-string regex="(@(.*?)@)" select="$text9">
            <xsl:matching-substring>
                <xsl:variable name="string">
                    <xsl:choose>
                        <xsl:when test="regex-group(2) = 'Nom.'">nominativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'nom.'">nominativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'gen.'">genitivus</xsl:when>
                        <xsl:when test="regex-group(2) = 'Gen.'">genitivus</xsl:when>
                        <xsl:when test="regex-group(2) = 'Acc.'">accusativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'acc.'">accusativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'Dat.'">dativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'dat.'">dativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'Abl.'">ablativus</xsl:when>
                        <xsl:when test="regex-group(2) = 'abl.'">ablativus</xsl:when>
                        <xsl:otherwise>not found</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <case>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$string"/>
                    </xsl:attribute>
                    <xsl:value-of select="regex-group(2)"/>
                </case>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text10" select="."/>
                <xsl:call-template name="gender">
                    <xsl:with-param name="text10" select="$text10"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:template name="gender">
        <xsl:param name="text10"/>
        <xsl:analyze-string regex="(ˆ(.*?)ˆ)" select="$text10">
            <xsl:matching-substring>
                <xsl:variable name="string">
                    <xsl:choose>
                        <xsl:when test="regex-group(2) = 'masc.'">masculinus</xsl:when>
                        <xsl:when test="regex-group(2) = 'fem.'">femininus</xsl:when>
                        <xsl:otherwise>not found</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <gen>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$string"/>
                    </xsl:attribute>
                    <xsl:value-of select="regex-group(2)"/>
                </gen>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text11" select="."/>
                <xsl:call-template name="sup">
                    <xsl:with-param name="text11" select="$text11"/>
                </xsl:call-template>

            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="sup">
        <xsl:param name="text11"/>
        <xsl:analyze-string regex="(ˆ!(.*?))" select="$text11">
            <xsl:matching-substring>
                <sup>
                    <xsl:value-of select="regex-group(2)"/>
                </sup>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text12" select="."/>
                <xsl:call-template name="note">
                    <xsl:with-param name="text12" select="$text12"/>
                </xsl:call-template>

            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="note">
        <xsl:param name="text12"/>
        <xsl:analyze-string regex="(!!(.*?)!!)" select="$text12">
            <xsl:matching-substring>
                <note>
                    <xsl:value-of select="regex-group(2)"/>
                </note>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="text13" select="."/>
                <xsl:call-template name="nd">
                    <xsl:with-param name="text13" select="$text13"/>
                </xsl:call-template>

            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="nd">
        <xsl:param name="text13"/>
        <xsl:analyze-string regex="\{{ND\}}" select="$text13">
            <xsl:matching-substring>
                <nd/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>