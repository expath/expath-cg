<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="http://expath.org/ns/houtil"
    package-version="0.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" 
    exclude-result-prefixes="#all" 
    version="3.0" 
    expand-text="true" 
    xmlns:houtil="http://expath.org/ns/houtil"
    xmlns:f="MyFunctions">

    <xsl:output method="xml" indent="true"/>

    <xsl:function name="houtil:highest" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType?"/>
        <xsl:sequence select="houtil:highestLowest($items, $key, true())"/>
    </xsl:function>
    
    <xsl:function name="houtil:lowest" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType?"/>
        <xsl:sequence select="houtil:highestLowest($items, $key, false())"/>
    </xsl:function>

    <xsl:function name="houtil:highestLowest" as="item()*">
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
                <xsl:when test="empty($value)">
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
        <xsl:sequence select="houtil:afterBefore($items, $condition, false(), true())"/>
    </xsl:function>
    
    <xsl:function name="houtil:to-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:afterBefore($items, $condition, true(), true())"/>
    </xsl:function>
    
    <xsl:function name="houtil:after-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:afterBefore($items, $condition, false(), false())"/>
    </xsl:function>
    
    <xsl:function name="houtil:from-first" as="item()*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence select="houtil:afterBefore($items, $condition, true(), false())"/>
    </xsl:function>

    <xsl:function name="houtil:afterBefore" as="item()*">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:param name="inclusive" as="xs:boolean"/>
        <xsl:param name="before" as="xs:boolean"/>
        <xsl:iterate select="$items">
            <xsl:param name="take" select="$before" as="xs:boolean"/>
            <xsl:choose>
                <xsl:when test="$before and $condition(.)">
                    <xsl:break select=".[$inclusive]"/>
                </xsl:when>
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
        <xsl:sequence select="houtil:transitive-closure($node, $fn, ())"/>
    </xsl:function>
    <xsl:function name="houtil:transitive-closure" as="node()*">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:param name="known" as="node()*"/>
        <xsl:variable name="mapped" as="node()*" select="$fn($node)"/>
        <xsl:variable name="new" select="$mapped except $known"/>
        <xsl:variable name="known" select="$known | $new"/>
        <xsl:sequence select="$known | ($new ! houtil:transitive-closure(., $fn, $known))"/>
    </xsl:function>
    <xsl:function name="houtil:is-reachable" as="xs:boolean" visibility="public">
        <xsl:param name="node1" as="node()"/>
        <xsl:param name="node2" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:sequence select="exists(houtil:is-reachable($node1, $node2, $fn, ()))"/>
    </xsl:function>
    <xsl:function name="houtil:is-reachable" as="node()?" visibility="public">
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
                    ($new ! houtil:is-reachable(., $node2, $fn, $known))"
        />
    </xsl:function>
    <xsl:function name="houtil:is-cyclic" as="xs:boolean" visibility="public">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="fn" as="function(node()) as node()*"/>
        <xsl:sequence select="exists(houtil:is-reachable($node, $node, $fn, ()))"/>
    </xsl:function>

    <xsl:function name="houtil:group-by" as="array(item()*)*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType"/>
        <xsl:for-each-group select="$items" group-by="$key(.)">
            <xsl:sequence select="[current-group()]"/>
        </xsl:for-each-group>
    </xsl:function>
    <xsl:function name="houtil:group-adjacent" as="array(item()*)*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="key" as="function(item()) as xs:anyAtomicType"/>
        <xsl:for-each-group select="$items" group-adjacent="$key(.)">
            <xsl:sequence select="[current-group()]"/>
        </xsl:for-each-group>
    </xsl:function>
    <xsl:function name="houtil:group-starting-with" as="array(item()*)*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:for-each-group select="$items" group-starting-with=".[$condition(.)]">
            <xsl:sequence select="[current-group()]"/>
        </xsl:for-each-group>
    </xsl:function>
    <xsl:function name="houtil:group-ending-with" as="array(item()*)*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:for-each-group select="$items" group-ending-with=".[$condition(.)]">
            <xsl:sequence select="[current-group()]"/>
        </xsl:for-each-group>
    </xsl:function>
    <xsl:function name="houtil:index-of" as="xs:integer*" visibility="public">
        <xsl:param name="items" as="item()*"/>
        <xsl:param name="condition" as="function(item()) as xs:boolean"/>
        <xsl:sequence
            select="
                $items ! (let $i := .,
                    $p := position()
                return
                    $p[$condition($i)])"
        />
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

   
    <xsl:function name="f:show-trail" as="node()">
        <xsl:param name="node" as="node()"/>
        <xsl:for-each select="$node">
            <xsl:copy>
                <xsl:sequence select="@*"/>
                <xsl:attribute name="reach" select="houtil:transitive-closure($node, $next-trail)/name()"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>

    <xsl:variable name="next-trail" select="
            function ($node) {
                root($node)//*[name() = $node/@next]
            }"/>

    <xsl:template name="xsl:initial-template">
        <xsl:variable name="numbers" select="1, 3, 1, 6, 1, 1, 8, 3, 12, 1, 1"/>
        <xsl:variable name="number.key" select="
                function ($val) {
                    $val mod 2
                }"/>
        <xsl:variable name="number.condition" select="
                function ($val) {
                    $val mod 2 eq 0
                }"/>
        <xsl:variable name="tree">
            <root>
                <A next="C"/>
                <B next="E"/>
                <C next="F"/>
                <D/>
                <E/>
                <F next="C"/>
            </root>
        </xsl:variable>

        <out>
            <numbers>{$numbers}</numbers>
            <key xsl:expand-text="false">function ($val) {$val mod 2}</key>
            <condition xsl:expand-text="false">function ($val) {$val mod 2 eq 0}</condition>
            <tree-trail xsl:expand-text="false">function($node) {root($node)//*[name() = $node/@next]}</tree-trail>
            <tree>
                <xsl:sequence select="$tree"/>
            </tree>
            <A>
                <highest>{houtil:highest($numbers,$number.key)}</highest>
                <lowest>{houtil:lowest($numbers,$number.key)}</lowest>
            </A>
            <B>
                <before-first>{houtil:before-first($numbers,$number.condition)}</before-first>
                <to-first>{houtil:to-first($numbers,$number.condition)}</to-first>
                <after-first>{houtil:after-first($numbers,$number.condition)}</after-first>
                <from-first>{houtil:from-first($numbers,$number.condition)}</from-first>
            </B>
            <C>
                <transitive-closure>
                    <xsl:sequence select="houtil:transitive-closure($tree//A, $next-trail)"/>
                </transitive-closure>
                <is-reachable from="">
                    <xsl:for-each select="$tree/root/*">
                        <xsl:variable name="start" select="."/>
                        <xsl:copy>
                            <xsl:sequence select="@*"/>
                            <xsl:sequence select="$tree/root/*/(name() || ':' || houtil:is-reachable($start, ., $next-trail))"/>
                        </xsl:copy>
                    </xsl:for-each>
                </is-reachable>
                <is-cyclic>
                    <xsl:sequence select="$tree/root/*/(name() || ':' || houtil:is-cyclic(., $next-trail))"/>
                </is-cyclic>
            </C>
            <D>
                <group-by>{houtil:group-by($numbers,$number.key) ! ("["||string-join(.?*,',')||"]")}</group-by>
                <group-adjacent>{houtil:group-adjacent($numbers,$number.key) ! ("["||string-join(.?*,',')||"]")}</group-adjacent>
                <group-starting-with>{houtil:group-starting-with($numbers,$number.condition) ! ("["||string-join(.?*,',')||"]")}</group-starting-with>
                <group-ending-with>{houtil:group-ending-with($numbers,$number.condition) ! ("["||string-join(.?*,',')||"]")}</group-ending-with>
                <index-of>{houtil:index-of($numbers,$number.condition)}</index-of>
            </D>
            <E>
                <replace>{houtil:replace("a123b56","\d+",'',function($in) {string(number($in)+1)})}</replace>
                <replace-captured-substrings>{houtil:replace-captured-substrings("a[123]b[56]", "\[(\d+)\]", "",
                    function($groups){string(number($groups(1))+1)})}</replace-captured-substrings>
            </E>
            <F>
                <transform-node-tree>
                    <xsl:sequence
                        select="houtil:transform-node-tree($tree/root, (map{'match': function($node) {exists($node/@next)}, 'action': f:show-trail#1}))"
                    />
                </transform-node-tree>
            </F>
        </out>
    </xsl:template>
</xsl:package>
