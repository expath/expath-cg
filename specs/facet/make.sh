#!/bin/bash

set -e

jing="java -jar ../../../../jing-20091111/bin/jing.jar"
saxon="java -jar ../../../../SaxonHE9-5-1-6J/saxon9he.jar"

# To convert md to xml:  install https://nodejs.org/, then "npm install markedtoc"
mtoc -x facet.md > facet.xml

# Using https://github.com/relaxng/jing-trang for xml schema validation
$jing -c ../../tools/xmlspec/src/xmlspec.rnc facet.xml

# convert xml to html
$saxon -s:facet.xml -xsl:../../tools/expathspec/src/xmlspec.xsl -o:facet.html

