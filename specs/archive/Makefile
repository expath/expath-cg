html/archive.html: src/archive-expanded.xml
	saxon -s:"$<" -xsl:style/xmlspec2html.xsl > "$@"

src/archive-expanded.xml: src/archive.xml
	saxon -s:"$<" -xsl:style/merge-function-specs.xsl > "$@"
