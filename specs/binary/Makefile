html/binary.html: src/binary-expanded.xml
	saxon -xsl:style/xmlspec2html.xsl -s:"$<" > "$@"

src/binary-expanded.xml: src/binary.xml
	saxon -xsl:style/merge-function-specs.xsl -s:"$<" > "$@"

html/binary-diff.html: diff/binary-expanded-diff.xml
	saxon -xsl:style/xmlspecDIFF2html.xsl -s:"$<" > "$@"
