<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml" xmlns:h="http://www.w3.org/1999/xhtml"
   xmlns:spec="http://expath.org/ns/xmlspec" xmlns:pkg="http://expath.org/ns/pkg"
   exclude-result-prefixes="#all" version="2.0">

   <xsl:import href="../../xmlspec/src/diffspec.xsl"/>
   <!-- <xsl:import href="http://w3.org/2002/xmlspec/diffspec.xsl"/>-->
   <xsl:import href="shared.xsl"/>

   <pkg:import-uri>http://expath.org/ns/xmlspec/diffspec.xsl</pkg:import-uri>

   <xsl:param name="additional.css">
      <!-- Parameter overriding cannot use the overrode param.  So I
           first include the original value copied and pasted from the
           original diffspec.xsl... -->
      <xsl:if test="$show.diff.markup != 0">
         <xsl:text>
            div.diff-add  { background-color: #FFFF99; }
            div.diff-del  { text-decoration: line-through; }
            div.diff-chg  { background-color: #99FF99; }
            div.diff-off  {  }

            span.diff-add { background-color: #FFFF99; }
            span.diff-del { text-decoration: line-through; }
            span.diff-chg { background-color: #99FF99; }
            span.diff-off {  }

            td.diff-add   { background-color: #FFFF99; }
            td.diff-del   { text-decoration: line-through }
            td.diff-chg   { background-color: #99FF99; }
            td.diff-off   {  }
         </xsl:text>
      </xsl:if>
      <!-- ...then the EXPath spec specific stuff. --> code.function { font-weight: bold; }
      code.type { font-style: italic; } body { <xsl:text>background-image: url(</xsl:text>
      <xsl:value-of select="( $logo-offline[$offline], $logo )[1]"/>
      <xsl:text>);</xsl:text> } </xsl:param>

   <!--
      Mode: postproc (extend it, defined in shared.xsl)
   -->

   <!-- replace div by span for locations in the header block -->
   <xsl:template
      match="h:div[@class eq 'head']/h:dl/h:dd/h:div[@class = ('diff-add', 'diff-del', 'diff-chg')][h:a]"
      mode="postproc">
      <span>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="node()" mode="postproc"/>
      </span>
   </xsl:template>

   <!-- replace div by span for both links in: "This document is also available
        in these non-normative formats: |XML| and |Revision markup|." -->
   <xsl:template
      match="h:div[@class eq 'head']/h:p/h:div[@class = ('diff-add', 'diff-del', 'diff-chg')][h:a]"
      mode="postproc">
      <span>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="node()" mode="postproc"/>
      </span>
   </xsl:template>

</xsl:stylesheet>
