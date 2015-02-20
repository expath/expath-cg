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

#editorial: http.html http-diff.html
editorial: http.html

http.html: http.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

http-diff.html: http-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@

http-20140228.html: http-20140228.xml
	saxon -s:$< -xsl:$(XMLSPEC) > $@

http-20140228-diff.html: http-20140228-diff.xml
	saxon -s:$< -xsl:$(DIFFSPEC) > $@
