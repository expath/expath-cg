@echo off
set SAXON=java -jar "c:\Program Files (x86)\Saxon\saxon9he.jar"
%SAXON% -s:xml/mongodb.xml -xsl:../../tools/expathspec/src/xmlspec.xsl >html/mongodb.html
rem %SAXON% -s:xml/mongodb-diff.xml -xsl:../../tools/expathspec/src/diffspec.xsl >file-diff.html
