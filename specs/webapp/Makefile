# If your EXPath repository contains both packages from ../../tools/
# (that is, xmlspec and expathspec), all you have to do to format the
# spec is (resp. for regular and diff versions):
#
# saxon -s:xxx.xml -xsl:http://expath.org/ns/xmlspec/xmlspec.xsl
# saxon -s:xxx.xml -xsl:http://expath.org/ns/xmlspec/diffspec.xsl
#
# The Packaging System spec require XInclude.

XMLSPEC=http://expath.org/ns/xmlspec/xmlspec.xsl
DIFFSPEC=http://expath.org/ns/xmlspec/diffspec.xsl
LATEST=20130319

editor: webapp.html
latest: webapp-$(LATEST).html webapp-$(LATEST)-diff.html

webapp.html: webapp.xml
	saxon -xi -s:$< -xsl:$(XMLSPEC) > $@

webapp-diff.html: webapp-diff.xml
	saxon -xi -s:$< -xsl:$(DIFFSPEC) > $@

webapp-$(LATEST).html: webapp-$(LATEST).xml
	saxon -xi -s:$< -xsl:$(XMLSPEC) > $@

webapp-$(LATEST)-diff.html: webapp-$(LATEST)-diff.xml
	saxon -xi -s:$< -xsl:$(DIFFSPEC) > $@
