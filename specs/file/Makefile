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

latest: file-20120614.html file-20120614-diff.html

file.html: file.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

file-diff.html: file-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@

file-20100517.html: file-20100517.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

file-20100517-diff.html: file-20100517-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@

file-20120614.html: file-20120614.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

file-20120614-diff.html: file-20120614-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@

file-20131203.html: file-20131203.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

file-20131203-diff.html: file-20131203-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@
