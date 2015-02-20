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
SAXON=saxon

latest: file-1.0.html file-1.0-diff.html

file.html: file.xml
	$(SAXON) -s:$< -xsl:$(XMLSPEC) > $@

file-diff.html: file-diff.xml
	$(SAXON) -s:$< -xsl:$(DIFFSPEC) > $@

file-20100517.html: file-20100517.xml
	$(SAXON) -s:$< -xsl:$(XMLSPEC) > $@

file-20100517-diff.html: file-20100517-diff.xml
	$(SAXON) -s:$< -xsl:$(DIFFSPEC) > $@

file-20120614.html: file-20120614.xml
	$(SAXON) -s:$< -xsl:$(XMLSPEC) > $@

file-20120614-diff.html: file-20120614-diff.xml
	$(SAXON) -s:$< -xsl:$(DIFFSPEC) > $@

file-20131203.html: file-20131203.xml
	$(SAXON) -s:$< -xsl:$(XMLSPEC) > $@

file-20131203-diff.html: file-20131203-diff.xml
	$(SAXON) -s:$< -xsl:$(DIFFSPEC) > $@

file-1.0.html: file-1.0.xml
	$(SAXON) -s:$< -xsl:$(XMLSPEC) > $@

file-1.0-diff.html: file-1.0-diff.xml
	$(SAXON) -s:$< -xsl:$(DIFFSPEC) > $@
