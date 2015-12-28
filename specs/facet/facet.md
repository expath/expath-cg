# Facet module
<header>
  <title>Facet Module</title>
  <w3c-designation>w3c-designation</w3c-designation>
  <w3c-doctype>EXPath Proposed Module</w3c-doctype>
  <pubdate>
     <day>25</day>
     <month>December</month>
     <year>2015</year>
  </pubdate>
  <publoc>
     <loc href="http://expath.org/spec/facet/20151225"/>
  </publoc>
  <authlist>
     <author role="editor">
        <name>Zed Zhou</name>
        <affiliation>EMC</affiliation>
     </author>
     <author role="editor">
        <name>Carla Spruit</name>
        <affiliation>EMC</affiliation>
     </author>
     <author role="contrib">
        <name>Jonathan Robie</name>
        <affiliation>EMC</affiliation>
     </author>
     <author role="contrib">
        <name>Bruno Marquie</name>
        <affiliation>EMC</affiliation>
     </author>
  </authlist>
  <copyright>
     <p>Published by the <loc
           href="http://w3.org/community/expath/">EXPath Community Group</loc> under the <loc
           href="https://www.w3.org/community/about/agreements/cla/">W3C Community Contributor
           License Agreement (CLA)</loc>. A human-readable <loc
           href="http://www.w3.org/community/about/agreements/cla-deed/">summary</loc> is
        available.</p>
     <p>This specification was published by the <loc href="http://www.w3.org/community/expath/"
           >EXPath Community Group</loc>. It is not a W3C Standard nor is it on the W3C
        Standards Track. Please note that under the <loc
           href="http://www.w3.org/community/about/agreements/cla/">W3C Community Contributor
           License Agreement (CLA)</loc> there is a limited opt-out and other conditions apply.s
        Learn more about <loc href="http://www.w3.org/community/">W3C Community and Business
           Groups</loc>.</p>
  </copyright>
  <abstract>
     <p>This proposal defines extension functions and data models to enable Faceted navigation/search
        support in XQuery.</p>
  </abstract>
  <status>
     <p/>
  </status>
  <langusage>
     <language>en-US</language>
  </langusage>
  <revisiondesc>
     <p>revisiondesc</p>
  </revisiondesc>
</header>

## Status of this document

This document is in an initial submission stage. Comments are welcomed at <loc href="mailto:zed.zhou@emc.com">here</loc>. 

## Introduction

Faceted search has proven to be enormously popular in the real world applications.  Faceted search allows user to navigate
 and access information via a structured facet classification system.  Combined with full text search, it provides user
 with enormous power and flexibility to discover information.
 
This proposal defines a standardized approach to support the Faceted search in XQuery.  It has been designed to be
compatible with XQuery 3.0, and is intended to be used in conjunction with XQuery and XPath Full Text 3.0.

### Namespace conventions

The module defined by this document defines functions and elements in the
namespace <code>http://expath.org/ns/facet</code>. In this document, the
<code>facet</code> prefix is bound to this namespace URI.

### Facet terminologies

* Facet:  refers to an object attribute (in a generic sense, not to be confused with xml attribute) that will be 
  aggregated.  For example,  "color" is a facet of "car" object.

* Facet-value: refers to a value of the facet.  For example, "blue" is a facet-value of the facet "color" for "car" object.

* The facet aggregation: counting the occurrence of each facet-value in the results.

* The facet drills:

    1.  drill-down: filter the search results by matching a selected facet value. Once a facet-value is drilled down,
        the facet is no longer available for selection by the user, thus only one facet-value in the same facet can be
        drilled-down at a time.  Example:

            - Color                                  - Color
              - blue(10)    -> User select blue  ->    x blue(10)
              - red(6)
              - yellow(2)
        
            * In UI, Color:blue is now shown as selected, the other values of facet "Color" are no longer
            available for further selection

    2.  drill-sideway:  also known as multi-select facets. Filter the search results by matching against multiple facet
        values of the same facet.  Example:

            - Color                         - Color                     - Color
              - blue(10)  -> select blue ->   x blue(10)  -> then red ->  x blue(10)
              - red(6)                        - red(6)                    x red(6)
              - yellow(2)                     - yellow(2)                 - yellow(2)

*  Hierarchical facets.  Organizing multiple facets in a hierarchical structure.  When
   a facet is a part of hierarchy, it must be aggregated in relation to its parent facet.  This concept
   is also sometimes referred to as pivot facet.
   
   For example:

        Flat facets                Hierarchical facets, "Color" is child of "Make"
        - Make                     - Make
          - Audi(10)                 - Audi(10)
                           ---->        - Color
        - Color                          - Blue(5)
          - Blue(10)
    
        * There are 10 blue cars in total, but only 5 blue Audi.


### The XQuery Extension

The faceted search support consists of the definitions of the facet data models, and the XQuery functions
that manipulate the data models to perform facet aggregation and drills.  The following sections contain
the detailed specification of the data models and the XQuery functions.  The [Use Cases](#use-cases) section contains
the examples demonstrating the application of this facet proposal with some sample data. 


## Schema

Below is the RelaxNG Compact grammar for the facet data models:

    default namespace facet = "http://expath.org/ns/facet"
    datatypes xs = "http://www.w3.org/2001/XMLSchema-datatypes"

    start = Facet

    Facet = element facet {
      attribute name { xs:string },
      element key {
          attribute value { xs:string },
          attribute count { xs:integer },
          attribute type  { xs:QName }?,
          AnyElement*,
          Facet*
      }*,
      AnyElement*
    }

    Facets = element facets {
        Facet*,
        AnyElement*
    }

    FacetDef = element facet-definition {
        attribute name { xs:string },
        element group-by {
            attribute function { xs:QName }?,
            attribute collation { xs:string }?,
            attribute type { xs:string }?,
            element sub-path { text } +,
            AnyElement*
        },
        element max-values { xs:integer }?,
        element order-by {
            attribute direction { "ascending" | "descending" },
            attribute empty { "greatest" | "least" }?,
            "value" | "count"
        }?,

        AnyElement*,
        FacetDef*,
    }

    # Denotes any element that does not belong to facet namespace
    AnyElement = element * - facet:* {
        ( attribute * - facet:* { text }
        | text 
        | AnyElement )*
    }

Example:

    <facet-definition xmlns="http://expath.org/ns/facet" name="Country">
        <group-by>
            <sub-path>location/country</sub-path>
        </group-by>
        <max-values>100</max-values>
        <order-by direction="ascending">value</order-by>
    </facet-definition>

    <facets xmlns="http://expath.org/ns/facet">
        <facet name="country">
            <key count="2" value="US"/>
        </facet>
    </facets>


### element facet

- attribute name : The facet name
- element key  : Contains all information pertaining to a facet grouping key. See the [element key](#element-key).
- AnyElement*  : For customization.

#### element key

- attribute value : The facet value
- attribute count : Number of occurrences counted for this facet value in the results
- attribute type  : Facet value data type,  always one of xs:anyAtomicType.  Optional attribute: when not specified, the default value is "xs:string".
- AnyElement*     : Any elements that do not belong to the facet namespace, for customization.
- element facet* :  Optional nested facets, for supporting hierarchical facets.

### element facets

- element facet* : Zero or more facet elements.
- AnyElement*    : For customization.

### element facet-definition

- attribute name : Defines the facet name.
- element group-by : Parameters for obtaining facet values from a sequence of items.  Facet value is similar to the
  concept of grouping key defined in the [group-by-clause](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#id-group-by).
  The key difference is that there is one and only one grouping key per result item, but there could be zero 
  or more facet value(s) per result item.  See this [section](#element-group-by) for more details.
- element max-values : Optional limit for maximum number of facet values to be returned, after ordering is applied.
- element order-by   : Optional ordering parameters to specify the order of returned facet values.  See this [section](#element-order-by).
- AnyElement*    : For customization.
- element facet-definition* : Optional nested facet definitions for supporting hierarchical facets.

#### element order-by

- attribute direction : One of "ascending" or "descending".  See [OrderModifier](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#prod-xquery31-OrderModifier)
- attribute empty     : One of "greatest" or "least".  See [OrderModifier](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#prod-xquery31-OrderModifier)
- content is one of
    - "value" : Order by /facet/key/@value
    - "count" : Order by /facet/key/@count, as xs:integer
- When ordering by "value", where the facet values are of xs:string type, and attribute collation is specified in
  the group-by element, implementation must order the string values using the specified collation.
- If order-by is not specified, then implementation must by default order by "count", with direction "descending".

#### element group-by

- attribute function : An optional string containing the QName of a function that returns customized facet values
- attribute collation : An optional string defined as [URILiteral](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#doc-xquery31-URILiteral).
  Collation is used to determine the equality of facet values of xs:string type.  See
  [group-by-clause](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#id-group-by) for the
  detailed semantics of this attribute.  If not specified, the default collation is used.
- attribute type : An optional string containing a xs:QName plus an optional [OccurrenceIndicator](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#prod-xquery31-OccurrenceIndicator).
  xs:QName must refer to a xs:anyAtomicType.
  When specified, strict type and cardinality checks are enforced on the facet values before
  they are counted.  See [group-by-clause](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#id-group-by)
  for the detailed semantics of this attribute.
- element sub-path
    - As defined by [selector-XPath](http://www.w3.org/TR/xmlschema11-1/#c-selector-xpath), the sub-path is relative to
      each item in the results sequence passed to the function "facet:count".
    - If attribute function is provided, then more than 1 sub-path may be specified , otherwise only 1 sub-path is
      allowed
- AnyElement*  : For customization.

The facet value grouping rules to obtain and count the facet values are mostly identical to the rules specified by [group-by-clause](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#id-group-by).
More specifically:

1.   For every item of the results sequence, the sub-path expressions are evaluated with the item as the context item.
2.   The results are then atomized to a sequence of zero or more atomic values.
3.   Apply the group-by function if specified.
     - If no group-by function exists, the atomized results from step 2 are the facet values.
     - If group-by function exists, the results from step 2 are passed to the group-by function.  The returned result
       from the group-by function are the facet values.
4.   If attribute type is specified, strong type and cardinality checks are performed on the facet values.  Error
     [err:XPTY0004](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#ERRXPTY0004) should be raised if check fails.
5.   Facet values are then counted using the same equality rule as defined by [group-by-clause](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#id-group-by),
     using the collation attribute when specified.

There exists a key difference between the grouping-key defined in [group-by-clause](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#id-group-by)
and the facet value.  The following rule for "grouping-key" does not apply to facet-value:

    If the value of any grouping variable consists of more than one item, a type error is raised [err:XPTY0004].

For facet, it's perfectly logical to have a result item to be counted towards multiple facet values or none at all, 
thus there may exist zero or more facet values per result item.

For conciseness, the following examples show the equivalent group-by clauses for some group-by elements, assuming
there is exactly one facet value (grouping key) per result item.

Example 1:

    group by $d := $item//sub-path
    order by count($item) descending

    <group-by>
        <sub-path>//sub-path</sub-path>
    </group-by>

Example 2:

    group by $d := local:group-function($item//sub-path)
    order by count($item) descending

    <group-by function="local:group-function">
        <sub-path>//sub-path</sub-path>
    </group-by>

Example 3:

    group by $d := local:group-function($item//sub-path) collation "Spanish"
    order by count($item) descending

    <group-by function="local:group-function" collation="Spanish">
        <sub-path>//sub-path</sub-path>
    </group-by>

Example 4:

    group by $d as xs:string := local:group-function($item//sub-path) collation "Spanish"
    order by count($item) descending

    <group-by function="local:group-function" collation="Spanish" type="xs:string">
        <sub-path>//sub-path</sub-path>
    </group-by>


## The function definitions

### facet:count

__Signature__

```inline-md
**facet:count**($results as _item()*_,
    $facet-definitions as _element(facet:facet-definition)*_) as _element(facet:facets)_
```

__Properties__

This function is: deterministic, context-independent, focus-independent

__Rules__

Given a result sequence, and a sequence of facet definitions, count the facet-values for each facet defined
by the facet definition(s).

### facet:drill

__Signature__

```inline-md
**facet:drill**($results as _item()*_,
    $facet-definition as _element(facet:facet-definition)_,
    $selected-facet as _element(facet:facet)_) as _item()*_
```

__Properties__

This function is: deterministic, context-independent, focus-independent

__Rules__

Given a result sequence, a facet definition, and a selected facet value contained in the facet element, return the
results that match the selected facet value.  This function can be used by both drill-down and drill-sideway queries.

In the case of hierarchical facets, the $selected-facet must have compatible hierarchical structure as $facet-definition.
This should be true by default if an application constructed $selected_facet from the facets element returned by facet:count
function using the same $facet-definition).  See use cases for more details.


### group-by function

__Signature__

```inline-md
**facet:group-by-function**($facet-definition as _element(facet:facet-definition)_,
    $sub-path-values as _xs:anyAtomicType*_,
    ...) as _xs:anyAtomicType*_;

```
    
__Properties__

This function is: deterministic, context-independent, focus-independent

__Rules__

The group-by function is supplied by the application, called by both facet:count and facet:drill.

The group-by function is a function that generates facet values from the original values.  Each item in the returned
sequence is a facet value that must be counted by facet:count, or compared against by facet:drill.  An empty
return sequence is also allowed.

As facet-definition's group-by element may define multiple sub-path child elements, the group-by function has arity
ranging from 2 to infinity.  The atomized sub-path values are passed to the group-by function in the same order as
defined in the group-by element.

Element facet-definition is also passed to the group-by function to allow an application to pass customized parameters
to the group-by function.

In the case of hierarchical facet definition, facet:count and facet:drill must pass in the matching
facet-definition element in the hierarchical structure to the group-by function.  For example:

    <facet-definition xmlns="http://expath.org/ns/facet" name="Country">
        <group-by>
          <sub-path>//country</sub-path>
        </group-by>
        <facet-definition name="region">    <!--  this is the facet-definition passed to local:group-by-region, instead
                                                  of the 'Country' facet-definition above-->
          <group-by function="local:group-by-region">
            <sub-path>//gps-coordinates</sub-path>
          </group-by>
        </facet-definition>
    </facet-definition>


## Use cases

For the use cases, we use the sample "employee" data in Appendix B.  Here is what one employee element looks like:

    <employee>
        <name>John Doe</name>
        <sex>Male</sex>
        <organization>HR</organization>
        <location>
          <country>USA</country>
          <state>CA</state>
          <city>Pleasanton</city>
        </location>
        <age>21</age>
        <employDate>2010-02-01</employDate>
        <skills>
          <skill>word</skill>
          <skill>excel</skill>
          <skill>windows</skill>
        </skills>
    </employee>

### Case 1: Simple facet based on existing attribute

The XQuery using this facet proposal:

    declare namespace facet = "http://expath.org/ns/facet";
    let $facetDefinition :=
      <facet:facet-definition name="Org">
        <facet:group-by>
          <facet:sub-path>organization</facet:sub-path>
        </facet:group-by>
      </facet:facet-definition>
    return facet:count( $employees, $facetDefinition )

The equivalent XQuery using group-by-clause, since employee belongs to one and only one organization:

    declare namespace facet = "http://expath.org/ns/facet";
    return
      <facet:facets>
        <facet:facet name='Org'>
          {
          for $e in $employees
          group by $org := $e/organization
          order by count($e) descending
          return <facet:key value="{ $org }" count="{ count($e) }"/>
          }
        </facet:facet>
      </facet:facets>

Expected result:

    <facets xmlns="http://expath.org/ns/facet">
      <facet name="Org">
        <key value="Sales" count="3"/>
        <key value="HR" count="2"/>
        <key value="Finance" count="1"/>
      </facet>
    </facets>


### Case 2: Simple customized facet based on group-by function

The XQuery using this facet proposal:

    declare namespace facet = "http://expath.org/ns/facet";
    declare function local:group-by-org($facetDef, $orgs) {
      if ($orgs = ('Sales', 'Finance'))
      then 'Sales and Finance'
      else 'Other departments'
    };

    let $facetDefinition :=
    <facet:facet-definition name="Org">
      <facet:group-by function="local:group-by-org">
        <facet:sub-path>organization</facet:sub-path>
      </facet:group-by>
    </facet:facet-definition>
    return facet:count($employees, $facetDefinition)

The equivalent XQuery using group-by-clause:

    declare namespace facet = "http://expath.org/ns/facet";
    declare function local:group-by-org ($facetVals) {
      if ($facetVals = ('Sales', 'Finance'))
      then 'Sales and Finance'
      else 'Other departments'
    };
    return
      <facet:facets>
        <facet:facet name="Org">
          {
          for $e in $employees
          group by $org := local:group-by-org($e/organization)
          order by count($e) descending
          return <facet:key value="{ $org }" count="{ count($e) }"/>
          }
        </facet:facet>
      </facet:facets>

Expected result:

    <facets xmlns="http://expath.org/ns/facet">
      <facet name="Org">
        <key value="Sales and Finance" count="4"/>
        <key value="Other departments" count="2"/>
      </facet>
    </facets>

### Case 3: Counting facets when the grouping key consists of more than 1 value

The XQuery using this facet proposal:

    declare namespace facet = "http://expath.org/ns/facet";
    let $facetDefinition :=
      <facet:facet-definition name="Skill">
        <facet:group-by>
          <facet:sub-path>skills/skill</facet:sub-path>
        </facet:group-by>
      </facet:facet-definition>
    return facet:count( $employees, $facetDefinition)

There is no equivalent XQuery using group-by-clause, because skill is a repeatable element.
Following XQuery will throw [err:XPTY0004](http://www.w3.org/TR/2014/WD-xquery-31-20140424/#ERRXPTY0004).

    declare namespace facet = "http://expath.org/ns/facet";
    <facet:facets>
      <facet:facet name="Skill">
        {
        for $e in $employees
        let $skill := $e/skills/skill
        group by $skill
        return <facet:key value="{ $skill }" count="{ count($e) }"/>
        }
      </facet:facet>
    </facet:facets>

Expected result:

     <facets xmlns="http://expath.org/ns/facet">
      <facet name="Skill">
        <key value="Word" count="4"/>
        <key value="PowerPoint" count="4"/>
        <key value="Excel" count="2"/>
        <key value="Windows" count="1"/>
        <key value="Linux" count="1"/>
        <key value="OpenOffice" count="1"/>
        <key value="PhotoShop" count="1"/>
        <key value="Negotiation" count="1"/>
      </facet>
    </facets>

### Case 4: Counting facets with group-by function strict type checking, and order by value with a collation

The XQuery using this facet proposal:

    declare namespace facet = "http://expath.org/ns/facet";
    declare function local:group-by-org($facetVals, $facetDef) {
      if ($facetVals = ('Sales', 'Finance'))
      then 'Sales and Finance'
      else 'Other departments'
    };

    let $facetDefinition :=
    <facet:facet-definition name="Org">
      <facet:group-by function="local:group-by-org" type='xs:string' collation='fr_FR'>
        <facet:sub-path>organization</facet:sub-path>
      </facet:group-by>
      <facet:order-by direction="ascending" empty='least'>value</facet:order-by>
    </facet:facet-definition>
    return facet:count(/employees/employee, $facetDefinition)

The equivalent XQuery using group-by-clause:

    declare namespace facet = "http://expath.org/ns/facet";
    declare function local:group-by-org($facetVals) {
      if ($facetVals = ('Sales', 'Finance'))
      then 'Sales and Finance'
      else 'Other departments'
    };
    <facet:facets>
      <facet:facet name='Org'>
        {
        for $e in /employees/employee
        group by $org as xs:string := local:group-by-org($e/organization) collation 'fr_FR'
        order by $org ascending empty least collation 'fr_FR'
        return <facet:key value="{ $org }" count="{ count($e) }"/>
        }
      </facet:facet>
    </facet:facets>

Expected result:

    <facets xmlns="http://expath.org/ns/facet">
      <facet name="Org">
        <key value="Other departments" count="2"/>
        <key value="Sales and Finance" count="4"/>
     </facet>
    </facets>

### Case 5: Hierarchical facet

The XQuery using this facet proposal:

    declare namespace facet = "http://expath.org/ns/facet";
    let $facetDefinition :=
        <facet-definition xmlns="http://expath.org/ns/facet">
            <name>State</name>
            <group-by>
                <sub-path>//state</sub-path>
            </group-by>
            <facet-definition>
                <name>Skill</name>
                <group-by>
                    <sub-path>//skill</sub-path>
                </group-by>
            </facet-definition>
        </facet-definition>
    return facet:count( $employees, $facetDefinition)

Expected result:

    <facets xmlns="http://expath.org/ns/facet">
      <facet name="State">
        <key count="3" value="WA">
            <facet name="Skill">
                <key count="2" value="Word"/>
                <key count="2" value="PowerPoint"/>
                <key count="1" value="OpenOffice"/>
                <key count="1" value="PhotoShop"/>
            </facet>
        </value
        <key count="2" value="CA">
            <facet name="Skill">
                <key count="2" value="Word"/>
                <key count="2" value="Excel"/>
                <key count="1" value="PowerPoint"/>
                <key count="1" value="Linux"/>
                <key count="1" value="Windows"/>
            </facet>
        </value
        <key count="1" value="OR">
            <facet name="Skill">
                <key count="1" value="PowerPoint"/>
                <key count="1" value="Negotiation"/>
            </facet>
        </value>
      </facet>
    </facets>

The application displays:

    State
    - WA (3)
      Skill
      x Word (2)     <=  User select this facet value
      - PowerPoint (2)
      - OpenOffice (1)
      - PhotoShop (1)
    - CA (2)
      Skill
      - Word (2)
      - Excel (2)
      - PowerPoint (1)
      - Linux (1)
      - Windows (1)
    - OR (1)
      Skill
      - PowerPoint (1)
      - Negotiation (1)

The application then constructs following facet element, based on user's selection:

    <facet xmlns="http://expath.org/ns/facet" name="State">
        <key count="2" value="WA">
            <facet name="Skill">
                <key count="2" value="Word"/>
            </facet>
        </value
    </facet>


The application then calls facet:drill, which is able to map the selected facet element to the facet-definition, 
and effectively applies following XQuery filter expression to the result set:

    $employee//state = "WA" and $employee//skill = "Word"

### Case 6: Hierarchical facet and drill sideway

Continuing from previous case, if the application allows user to simultaneously select multiple skills:

    State
    - WA (3)
      Skill
      - Word (2)
      - PowerPoint (2)
      - OpenOffice (1)
      - PhotoShop (1)
    - CA (2)
      Skill
      x Word (2)          <=  User select this facet value
      x Excel (2)         <=  and this facet value
      - PowerPoint (1)
      - Linux (1)
      - Windows (1)
    - OR (1)
      Skill
      - PowerPoint (1)
      - Negotiation (1)

The application then constructs following two facet elements, based on user's selection:

    let $selected-facet1 :=
    <facet xmlns="http://expath.org/ns/facet" name="State">
        <key count="2" value="CA">
            <facet name="Skill">
                <key count="2" value="Word"/>
            </facet>
        </value
    </facet>

    let $selected-facet2 :=
    <facet xmlns="http://expath.org/ns/facet" name="State">
        <key count="2" value="CA">
            <facet name="Skill">
                <key count="1" value="Excel"/>
            </facet>
        </value
    </facet>

And constructs the following XQuery:

    for $e in $employees[
        facet:drill(., $facet-definition, $selected-facet1) or
        facet:drill(., $facet-definition, $selected-facet2)
    ] return $e

Which is effectively the same as:

    for $e in $employees[
        (//state = 'CA' and //skill = 'Word') or
        (//state = 'CA' and //skill = 'Excel')
    ] return $e

# Back

## Issues list

### Issue 1. Use annotations to associate a grouping function to a facet-definition

As an alternative to specifying a function QName in /facet-definition/group-by/@function, annotation
may be used to associate a grouping function to a facet-definition.

Example:

    <facet-definition xmlns="http://expath.org/ns/facet" name="age">
        <group-by function="age-range">
            <sub-path>//age</sub-path>
        </group-by>
    </facet-definition>

    declare function %facet:group-by("age-range")local:age-range(
      $facet-definition as element(facet:facet-definition)
      $ages as xs:anyAtomicType*,
    ) as xs:anyAtomicType* {
        (: .... :)
    }

In the example above, annotation "age-range" is used to associated the facet-definition to the function local:age-range.

Annotation introduces an additional level of indirection to link a facet-definition to a group-by function.  The 
indirection does not appear to improve or simplify the API.  Thus currently we chose the straight forward function 
QName association via attribute.

### Issue 2. Facet drill optimization and customizations

When facet:drill encounters a facet-definition that defines a group-by function, it's effectively filtering results
using the following XQuery expression:

    $selected-facet-value = group-by-function($facet-def, $result)

One main draw back of the above filtering implementation is that it voids any indexing optimization.  To illustrate
this, lets use a common numeric range facet as an example.

Suppose we've customized the following age range facet based on the same *employee* data in the use-cases above:

    <facet-definition xmlns="http://expath.org/ns/facet" name="Age Range">
        <group-by function="local:group-by-range">
            <sub-path>//age</sub-path>
        </group-by>
    </facet-definition>
    
    declare function local:group-by-range(
      $facet-definition as element(facet:facet-definition)
      $ages as xs:anyAtomicType*,
    ) as xs:anyAtomicType* {
      for $age in $ages return 
        if (xs:integer($age) <20 ) then "<20";
        else if (xs:integer($age) <30 ) then "20-30";
        else "30+"
    }

Default facet:filter implementation translates to the following equivalent XQuery expression:

	(: ... other constraints ... :) and $selected-age-range = local:group-by-range($employee//age)

Application may choose to perform facet drill by directly constructing following XQuery expression:

	(: ... other constraints ... :) and $employee//age < 20   (: if $selected-age-range is "<20" :)

The above XQuery constraint expression can be optimized by the engine to use the index, 
which is clearly faster than using the default facet:drill implementation.

Another example is the 'dynamic-age-range' facet, where the age range is determined by the minimum and
the maximum age values in the result set.  In this case the result set must be pre-scanned before facet:count in order 
to determine the dynamic range, and the range information must be persisted into *facet* element to make facet drill query
possible later on.  These types of dynamic facets will require an application to implement customization, in addition
to just using the standard methods/approaches described in this proposal.

To completely support all possible real world facet requirements may be too complex for this proposal.  For this
reason we've decided to make *facet* and *facet-definition* elements extensible by allowing the inclusion of non
facet namespace elements.  The implementation will then be able to choose to offer full support for above mentioned
optimization and customizations via extensions.


## Sample data for the use cases

The complete sample data used by the use cases, presented as an XQuery.

    let $sample :=
    <sample>
      <employee>
        <name>John Doe</name>
        <sex>Male</sex>
        <organization>HR</organization>
        <location>
          <country>US</country>
          <state>CA</state>
          <city>Pleasanton</city>
          <gps>
            <longitude>-95.677068</longitude>
            <latitude>37.0625</latitude>
          </gps>
        </location>
        <age>21</age>
        <employDate>2010-02-01</employDate>
        <skills>
          <skill>Word</skill>
          <skill>Excel</skill>
          <skill>Windows</skill>
        </skills>
      </employee>

      <employee>
        <name>Jane Joe</name>
        <sex>Female</sex>
        <organization>Finance</organization>
        <location>
          <country>US</country>
          <state>CA</state>
          <city>San Francisco</city>
          <gps>
            <longitude>-122.419416</longitude>
            <latitude>37.77493</latitude>
          </gps>
        </location>
        <age>18</age>
        <employDate>2003-02-01</employDate>
        <skills>
          <skill>Word</skill>
          <skill>Excel</skill>
          <skill>PowerPoint</skill>
          <skill>Linux</skill>
        </skills>
      </employee>

      <employee>
        <name>Steve</name>
        <sex>Male</sex>
        <organization>HR</organization>
        <location>
          <country>US</country>
          <state>WA</state>
          <city>Seattle</city>
          <gps>
            <longitude>-122.332071</longitude>
            <latitude>47.60621</latitude>
          </gps>
        </location>
        <age>31</age>
        <employDate>2010-04-01</employDate>
        <skills>
          <skill>OpenOffice</skill>
          <skill>Word</skill>
        </skills>
      </employee>

      <employee>
        <name>Kylie</name>
        <sex>Female</sex>
        <organization>Sales</organization>
        <location>
          <country>US</country>
          <state>WA</state>
          <city>Bellingham</city>
          <gps>
            <longitude>-122.488225</longitude>
            <latitude>48.759553</latitude>
          </gps>
        </location>
        <age>23</age>
        <employDate>2010-06-01</employDate>
        <skills>
          <skill>Word</skill>
          <skill>PowerPoint</skill>
        </skills>
      </employee>

      <employee>
        <name>Kyle</name>
        <sex>Male</sex>
        <organization>Sales</organization>
        <location>
          <country>US</country>
          <state>WA</state>
          <city>Bellingham</city>
          <gps>
            <longitude>-122.499225</longitude>
            <latitude>48.759553</latitude>
          </gps>
        </location>
        <age>45</age>
        <employDate>2009-06-01</employDate>
        <skills>
          <skill>PowerPoint</skill>
          <skill>PhotoShop</skill>
        </skills>
      </employee>

      <employee>
        <name>Mike</name>
        <sex>Male</sex>
        <organization>Sales</organization>
        <location>
          <country>US</country>
          <state>OR</state>
          <city>Eugene</city>
          <gps>
            <longitude>-123.086754</longitude>
            <latitude>44.052069</latitude>
          </gps>
        </location>
        <age>55</age>
        <employDate>1999-06-01</employDate>
        <skills>
          <skill>PowerPoint</skill>
          <skill>Negotiation</skill>
        </skills>
      </employee>

    </sample>

    let $employees := $sample/employee



