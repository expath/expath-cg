# If your EXPath repository contains both packages in ../../tools/
# (that is, xmlspec and expathspec), all you have to do to format the
# spec is (resp. for regular and diff versions):
#
# saxon -s:xxx.xml -xsl:http://expath.org/ns/xmlspec/xmlspec.xsl
# saxon -s:xxx.xml -xsl:http://expath.org/ns/xmlspec/diffspec.xsl
#
# The Packaging System spec require XInclude.

XMLSPEC=http://expath.org/ns/xmlspec/xmlspec.xsl
DIFFSPEC=http://expath.org/ns/xmlspec/diffspec.xsl

editorial: pkg.html pkg-diff.html

pkg.html: pkg.xml
	saxon -xi -s:$< -xsl:$(XMLSPEC) > $@

pkg-diff.html: pkg-diff.xml
	saxon -xi -s:$< -xsl:$(DIFFSPEC) > $@

pkg-20120509.html: pkg-20120509.xml
	saxon -xi -s:$< -xsl:$(XMLSPEC) > $@

pkg-20120509-diff.html: pkg-20120509-diff.xml
	saxon -xi -s:$< -xsl:$(DIFFSPEC) > $@
