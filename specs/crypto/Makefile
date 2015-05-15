# If your EXPath repository contains both packages in ../../tools/
# (that is, xmlspec and expathspec), all you have to do to format the
# spec is (resp. for regular and diff versions):
#
# saxon -s:xxx.xml -xsl:http://expath.org/ns/xmlspec/xmlspec.xsl
# saxon -s:xxx.xml -xsl:http://expath.org/ns/xmlspec/diffspec.xsl

#XMLSPEC=http://expath.org/ns/xmlspec/xmlspec.xsl
#DIFFSPEC=http://expath.org/ns/xmlspec/diffspec.xsl
XMLSPEC=../../tools/expathspec/src/xmlspec.xsl
DIFFSPEC=../../tools/expathspec/src/diffspec.xsl

#editorial: crypto.html crypto-diff.html
editorial: crypto.html

crypto.html: crypto.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

crypto-diff.html: crypto-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@

crypto-20150214.html: crypto-20150214.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

crypto-20150214-diff.html: crypto-20150214-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@

# crypto-20110810.html: crypto-20110810.xml
# 	saxon -s:$< -xsl:$(XMLSPEC) > $@
