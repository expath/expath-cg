<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace"
  xmlns:ex="http://expath.org/ns/xmlspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"  xmlns:doc="http://jwlresearch.net/2012/doc" exclude-result-prefixes="xs math"
  version="3.0">
  
  <doc:doc title="W3C function-catalog extractor">
    <p>This stylesheet attempts to extract a function catalog from a specification</p>
  </doc:doc>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:template match="/">
    <fos:functions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.w3.org/xpath-functions/spec/namespace fos.xsd"
      xmlns:ex="http://expath.org/ns/xmlspec"
      xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace">
      <xsl:apply-templates select="//div2[starts-with(@id,'fn.') or starts-with(@id,'pr.')]"/>
    </fos:functions>
  </xsl:template>
  <xsl:template match="div2">
    <fos:function name="{replace(head,'\i\c*:','')}" prefix="file">
      <xsl:apply-templates select="* except head"/>
    </fos:function>
  </xsl:template>

  <xsl:template match="gitem[label='Signature']">
    <fos:signatures>
      <xsl:apply-templates select="def//eg"/>
    </fos:signatures>
  </xsl:template>
  <xsl:template match="gitem[label='Rules']">
    <fos:summary>
      <xsl:apply-templates select="def/p[1]"/>
    </fos:summary>
    <fos:rules>
      <xsl:apply-templates select="def/*"/>
    </fos:rules>
  </xsl:template>
  <xsl:template match="gitem[label='Error Conditions']">
    <fos:errors>
      <xsl:apply-templates select="def/*"/>
    </fos:errors>
  </xsl:template>

  <xsl:template match="eg">
    <xsl:for-each-group select="*|text()" group-starting-with="ex:function" bind-group="g">
      <xsl:if test="matches(string-join($g,''),'\S')">
        <fos:proto name="{replace($g/self::ex:function,'\i\c*:','')}">
          <xsl:variable name="types" as="element()*">
            <xsl:for-each-group select="$g[not(self::ex:function)]" group-ending-with="ex:type"
              bind-group="t">
              <xsl:if test="matches(string-join($t,''),'\S')">
                <fos:arg>
                  <xsl:attribute name="type" select="$t/self::ex:type" on-empty="()"/>
                  <xsl:analyze-string select="string-join($t,'')" regex="\$(\i\c*)">
                    <xsl:matching-substring>
                      <xsl:attribute name="name" select="regex-group(1)"/>
                    </xsl:matching-substring>
                  </xsl:analyze-string>
                </fos:arg>
              </xsl:if>
            </xsl:for-each-group>
          </xsl:variable>
          <xsl:attribute name="return-type" select="$types[empty(@name)]/@type"/>
          <xsl:sequence select="$types[@name]"/>
        </fos:proto>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>
</xsl:stylesheet>
