@echo off
set EXPATH_REPO=c:\expath
call c:\expath-repo\bin\saxon.bat -xsl:style\merge-function-specs.xsl -s:src\binary.xml -o:src\binary-expanded.xml
call c:\expath-repo\bin\saxon.bat -xsl:style\xmlspec2html.xsl -s:src/binary-expanded.xml -o:html/binary.html

