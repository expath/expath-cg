<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="http://expath.org/ns/houtil"
    package-version="0.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:houtil="http://expath.org/ns/houtil"
    version="3.0" 
    expand-text="true">

    <xsl:output method="xml" indent="true"/>

    <xsl:function name="houtil:highest" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType?"/>
        <xsl:sequence select="houtil:_highestLowest($items, $key, true())"/>
    </xsl:function>
    
    <xsl:function name="houtil:lowest" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType?"/>
        <xsl:sequence select="houtil:_highestLowest($items, $key, false())"/>
    </xsl:function>

    <xsl:function name="houtil:_highestLowest" as="item()*" visibility="private">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType?"/>
        <xsl:param name="highest" as="xs:boolean"/>
        <xsl:iterate select="$items">
            <xsl:param name="chosen" select="()" as="item()*"/>
            <xsl:param name="value" select="()" as="xs:anyAtomicType?"/>
            <xsl:on-completion select="$chosen"/>
            <xsl:variable name="keyValue" select="$key(.)"/>
            <xsl:variable name="keyValue" select="if ($keyValue instance of xs:untypedAtomic) then xs:double($keyValue) else $keyValue"/>
            <xsl:choose>
                <xsl:when test="empty($keyValue)"/>
                <xsl:when test="$keyValue ne $keyValue (: $keyValue is NaN :)"/>
                <xsl:when test="empty($value) (: first significant item in input :)">
                    <xsl:next-iteration>
                        <xsl:with-param name="chosen" select="."/>
                        <xsl:with-param name="value" select="$keyValue[not(. lt .)] (: force an error if the type is unordered :)"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:when test="$keyValue eq $value">
                    <xsl:next-iteration>
                        <xsl:with-param name="chosen" select="$chosen, ."/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:when test="$highest and $keyValue gt $value">
                    <xsl:next-iteration>
                        <xsl:with-param name="chosen" select="."/>
                        <xsl:with-param name="value" select="$keyValue"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:when test="not($highest) and $keyValue lt $value">
                    <xsl:next-iteration>
                        <xsl:with-param name="chosen" select="."/>
                        <xsl:with-param name="value" select="$keyValue"/>
                    </xsl:next-iteration>
                </xsl:when>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>

    <xsl:function name="houtil:before-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:_before($items, $condition, false())"/>
    </xsl:function>
    
    <xsl:function name="houtil:to-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:_before($items, $condition, true())"/>
    </xsl:function>
    
    <xsl:function name="houtil:_before" as="item()*" visibility="private">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:param name="inclusive" as="xs:boolean"/>
        <xsl:iterate select="$items">
            <xsl:choose>
                <xsl:when test="$condition(.)">
                    <xsl:break select=".[$inclusive]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>
    
    <xsl:function name="houtil:after-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:_after($items, $condition, false())"/>
    </xsl:function>
    
    <xsl:function name="houtil:from-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:_after($items, $condition, true())"/>
    </xsl:function>

    <xsl:function name="houtil:_after" as="item()*" visibility="private">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:param name="inclusive" as="xs:boolean"/>
        <xsl:iterate select="$items">
            <xsl:param name="take" select="false()" as="xs:boolean"/>
            <xsl:choose>
                <xsl:when test="not($take) and $condition(.)">
                    <xsl:sequence select=".[$inclusive]"/>
                    <xsl:next-iteration>
                        <xsl:with-param name="take" select="true()"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select=".[$take]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>

    <xsl:function name="houtil:transitive-closure" as="node()*" visibility="public">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:sequence select="houtil:_transitive-closure($node, $fn, ())"/>
    </xsl:function>
    
    <xsl:function name="houtil:_transitive-closure" as="node()*" visibility="private">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:param name="known" as="node()*"/>
        <xsl:variable name="mapped" as="node()*" select="$fn($node)"/>
        <xsl:variable name="new" select="$mapped except $known"/>
        <xsl:variable name="known" select="$known | $new"/>
        <xsl:sequence select="$known | ($new ! houtil:_transitive-closure(., $fn, $known))"/>
    </xsl:function>
    
    <xsl:function name="houtil:is-reachable" as="xs:boolean" visibility="public">
        <xsl:param name="node1" as="node()"/>
        <xsl:param name="node2" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:sequence select="exists(houtil:_is-reachable($node1, $node2, $fn, ()))"/>
    </xsl:function>
    
    <xsl:function name="houtil:_is-reachable" as="node()?" visibility="private">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="node2" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:param name="known" as="node()*"/>
        <xsl:variable name="mapped" as="node()*" select="$fn($node)"/>
        <xsl:variable name="new" select="$mapped except $known"/>
        <xsl:variable name="known" select="$known | $new"/>
        <xsl:sequence
            select="
                if ($new[. is $node2]) then
                    $node2
                else
                    ($new ! houtil:_is-reachable(., $node2, $fn, $known))"
        />
    </xsl:function>
    <xsl:function name="houtil:is-cyclic" as="xs:boolean" visibility="public">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:sequence select="exists(houtil:_is-reachable($node, $node, $fn, ()))"/>
    </xsl:function>

    <xsl:function name="houtil:group-by" as="map(xs:anyAtomicType, item()*)" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType?"/>
        <xsl:sequence select="map:merge($items ! (let $k := $key(.) return (if (exists($k)) then map{$k : .} else ())), map{'duplicates':'combine'})"/>
    </xsl:function>
    
    <xsl:function name="houtil:group-adjacent" as="array(item())*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType"/>
        <xsl:iterate select="$items">
            <xsl:param name="prev" as="xs:anyAtomicType?" select="()"/>
            <xsl:param name="lastGroup" as="array(item())" select="[]"/>
            <xsl:on-completion select="$lastGroup"/>
            <xsl:variable name="k" select="$key(.)"/>
            <xsl:choose>
                <xsl:when test="empty($prev)">
                    <xsl:next-iteration>
                        <xsl:with-param name="prev" select="$k"/>
                        <xsl:with-param name="lastGroup" select="[.]"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:when test="houtil:_same-key($k, $prev)">
                    <xsl:next-iteration>
                        <xsl:with-param name="lastGroup" select="array:append($lastGroup, .)"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$lastGroup"/>
                    <xsl:next-iteration>
                        <xsl:with-param name="prev" select="$k"/>
                        <xsl:with-param name="lastGroup" select="[]"/>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>
    
    <xsl:function name="houtil:_same-key" as="xs:boolean" visibility="private">
        <xsl:param name="a" as="xs:anyAtomicType"/>
        <xsl:param name="b" as="xs:anyAtomicType"/>
        <xsl:sequence select="map:contains(map{$a: 0}, $b)"/>
    </xsl:function>
    
    <xsl:function name="houtil:group-starting-with" as="array(item())*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:for-each-group select="$items" group-starting-with=".[$condition(.)]">
            <xsl:sequence select="[current-group()]"/>
        </xsl:for-each-group>
    </xsl:function>
    <xsl:function name="houtil:group-ending-with" as="array(item())*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:for-each-group select="$items" group-ending-with=".[$condition(.)]">
            <xsl:sequence select="[current-group()]"/>
        </xsl:for-each-group>
    </xsl:function>
    
    <xsl:function name="houtil:index-of" as="xs:integer*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:for-each select="$items">
            <xsl:sequence select="position()[$condition(current())]"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="houtil:replace" as="xs:string*" visibility="public">
        <xsl:param name="input" as="xs:string"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:param name="flags" as="xs:string"/>
        <xsl:param name="fn" as="function(xs:string) as xs:string"/>
        <xsl:variable name="parts" as="xs:string*">
            <xsl:analyze-string select="$input" flags="{$flags}" regex="{$regex}">
                <xsl:matching-substring>
                    <xsl:sequence select="$fn(.)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($parts)"/>
    </xsl:function>

    <xsl:function name="houtil:replace-captured-substrings" as="xs:string*" visibility="public">
        <xsl:param name="input" as="xs:string"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:param name="flags" as="xs:string"/>
        <xsl:param name="fn" as="function(function(xs:integer) as xs:string) as xs:string"/>
        <xsl:variable name="parts" as="xs:string*">
            <xsl:analyze-string select="$input" flags="{$flags}" regex="{$regex}">
                <xsl:matching-substring>
                    <xsl:variable name="groups" select="(0 to 10) ! regex-group(.)"/>
                    <xsl:variable name="groups"
                        select="
                            function ($index) {
                                subsequence($groups, $index + 1, 1)
                            }"/>
                    <xsl:sequence select="$fn($groups)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($parts)"/>
    </xsl:function>

    <xsl:function name="houtil:transform-node-tree" as="node()*" visibility="public">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="rules" as="map(xs:string,function(*))*"/>
        <xsl:apply-templates select="$nodes" mode="houtil:transform-node-tree">
            <xsl:with-param name="rules" select="$rules" tunnel="true"/>
        </xsl:apply-templates>
    </xsl:function>
    <xsl:mode name="houtil:transform-node-tree" on-no-match="shallow-copy"/>
    <xsl:template match="node()" mode="houtil:transform-node-tree" as="node()*">
        <xsl:param name="rules" as="map(xs:string,function(*))*" tunnel="true"/>
        <xsl:variable name="matching.rules"
            select="
                let $c := current()
                return
                    filter($rules, function ($r) {
                        $r?match($c)
                    })"/>
        <xsl:choose>
            <xsl:when test="exists($matching.rules)">
                <xsl:sequence select="head($matching.rules)?action(current())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

 
</xsl:package>
