<!DOCTYPE xsl:stylesheet [
  <!ENTITY nl "&#x0A;">
]>

<xsl:stylesheet
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns='http://www.w3.org/1999/xhtml'
                xmlns:r='http://berjon.com/ns/re-spec/'
                xmlns:c='http://berjon.com/ns/xslt-conf/'
                xmlns:rng='http://relaxng.org/ns/structure/1.0'
                xmlns:str='http://exslt.org/strings'
                extension-element-prefixes='str'
                exclude-result-prefixes='r c rng'
                version='1.0'>

  <xsl:output
              method='xml'
              media-type='application/xhtml+xml'
              encoding='UTF-8'
              indent='yes'
              doctype-public='-//W3C//DTD XHTML 1.0 Strict//EN'
              doctype-system='http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
              />

  <!-- **********************************************************************
      basic configuration and parameters
          - specType: robin or W3C, decides the style to use
          - specStatus: 
                  ED  - editor's draft
                  N   - a note
                  INF - an informal document
                  MO  - member only
                  WD, LC, CR, PR, REC - the obvious
          - lang: the language
          - title: the title
          - editors: the editors
  -->
  <xsl:variable name='specType' select='/r:*/r:metadata/r:styling/@type'/>
  <xsl:variable name='specStatus' select='/r:*/r:metadata/r:styling/@status'/>
  <xsl:variable name='lang'>
      <xsl:choose>
          <xsl:when test='/r:*/@xml:lang'><xsl:value-of select='/r:*/@xml:lang'/></xsl:when>
          <xsl:otherwise>en</xsl:otherwise>
      </xsl:choose>
  </xsl:variable>
  <xsl:variable name='title' select='/r:*/r:metadata/r:title'/>
  <xsl:variable name='editors' select='/r:*/r:metadata/r:editors/r:person'/>
  <xsl:variable name='pubDate' select='/r:*/r:metadata/r:date'/>

  <date xmlns='http://berjon.com/ns/xslt-conf/'>
    <item key='01'>January</item>
    <item key='02'>February</item>
    <item key='03'>March</item>
    <item key='04'>April</item>
    <item key='05'>May</item>
    <item key='06'>June</item>
    <item key='07'>July</item>
    <item key='08'>August</item>
    <item key='09'>September</item>
    <item key='10'>October</item>
    <item key='11'>November</item>
    <item key='12'>December</item>
  </date>
  <xsl:variable name='humanDate'>
    <xsl:value-of select='$pubDate/@day'/><xsl:text> </xsl:text>
    <xsl:value-of select='document("")//c:date/c:item[@key = $pubDate/@month]'/><xsl:text> </xsl:text>
    <xsl:value-of select='$pubDate/@year'/>
  </xsl:variable>

  <skip-toc xmlns='http://berjon.com/ns/xslt-conf/'>
    <item key='abstract'/>
    <item key='w3c-abstract'/>
    <item key='w3c-sotd'/>
    <item key='toc'/>
    <item key='appendix'/>
  </skip-toc>
  <xsl:variable name='noTOC' select='document("")//c:skip-toc/c:item'/>


  <!-- **********************************************************************
      basic processing
  -->

  <xsl:template match='r:specification'>
        <xsl:comment>
          ******* WARNING ********
          This document was automatically generated using the Re-Spec specification
          publishing system. Edits made here are likely to be lost when it is
          regenerated.
          ******* WARNING ********
        </xsl:comment>
        <html xmlns='http://www.w3.org/1999/xhtml' xml:lang='{$lang}'>
            <head>
                <title><xsl:value-of select='$title'/></title>
                <!-- @@ throw in some extra headers for author, etc -->
                <xsl:call-template name='type-specific-header'/>
            </head>
            <body>
                <xsl:call-template name='type-specific-body'/>
                <xsl:apply-templates/>
                <xsl:call-template name='type-specific-footer'/>
            </body>
        </html>
    </xsl:template>

  <xsl:template match='r:section'>
    <div class='section'>
      <xsl:element name='h{count(ancestor::r:section)+2}' namespace='http://www.w3.org/1999/xhtml'>
        <xsl:attribute name='id'><xsl:value-of select='@xml:id'/></xsl:attribute>
				<xsl:choose>
					<xsl:when test='not($noTOC/@key = @type)'>
            <xsl:call-template name='get-section-number'>
              <xsl:with-param name='section' select='.'/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
					</xsl:when>
					<xsl:when test='@type = "appendix"'>
            <xsl:number format='A' value='count(preceding-sibling::r:section[@type = "appendix"]) + 1'/>
            <xsl:text>. </xsl:text>
					</xsl:when>
				</xsl:choose>
        <xsl:apply-templates select='r:title/node()'/>
      </xsl:element>
      <xsl:if test='@normativity="informative"'>
        <p><strong>This section is informative.</strong></p>
      </xsl:if>
      <xsl:if test='@normativity="not normative"'>
        <p><strong>This section is not normative normative.</strong></p>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match='r:dfn'>
    <dfn id='dfn-{translate(normalize-space(.), " ABCDEFGHIJKLMNOPQRSTUVWXYZ", "-abcdefghijklmnopqrstuvwxyz")}'>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:apply-templates/>
    </dfn>
  </xsl:template>

  <xsl:template match='r:term'>
    <a class='term' href='#dfn-{translate(normalize-space(.), " ABCDEFGHIJKLMNOPQRSTUVWXYZ", "-abcdefghijklmnopqrstuvwxyz")}'>
      <xsl:if test='@xml:id'>
        <xsl:attribute name='id'><xsl:value-of select='@xml:id'/></xsl:attribute>
      </xsl:if>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!-- the HTML elements -->
  <xsl:template match='r:p | r:a | r:abbr | r:acronym | r:code | r:dl | r:dd |
                       r:dt | r:ol | r:ul | r:li | r:table | r:thead | r:tbody | r:tfoot |
                       r:caption | r:tr | r:th | r:td | r:em | r:strong | r:br | r:cite | r:q |
                       r:span | r:var | r:pre'>
    <xsl:element name='{local-name()}' namespace='http://www.w3.org/1999/xhtml'>
      <xsl:if test='@xml:id'>
        <xsl:attribute name='id'><xsl:value-of select='@xml:id'/></xsl:attribute>
      </xsl:if>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='r:rfc2119'>
    <em class='rfc2119' title='Keyword in RFC 2119 context'><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match='r:bibref'>
    <cite><a href='#{text()}' class='bibref'><xsl:apply-templates/></a></cite>
  </xsl:template>

  <xsl:template match='r:at'>
    <xsl:choose>
      <xsl:when test='ancestor::r:title'>
        '<code class='attr-name'><xsl:apply-templates/></code>'
      </xsl:when>
      <xsl:otherwise>
        '<a href='#attr-{text()}' class='attr-name'>
          <xsl:attribute name='href'>
            <xsl:text>#attr-</xsl:text>
            <xsl:if test='@el'><xsl:value-of select='@el'/>-</xsl:if>
            <xsl:value-of select='text()'/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>'
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='r:prop'>
    <xsl:choose>
      <xsl:when test='ancestor::r:title'>
        '<code class='prop-name'><xsl:apply-templates/></code>'
      </xsl:when>
      <xsl:otherwise>
        '<a href='#prop-{text()}' class='prop-name'><xsl:apply-templates/></a>'
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='r:ev'>
    <xsl:choose>
      <xsl:when test='ancestor::r:title'>
        '<code class='event-name'><xsl:apply-templates/></code>'
      </xsl:when>
      <xsl:otherwise>
        '<a href='#event-{text()}' class='event-name'><xsl:apply-templates/></a>'
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='r:el'>
    <xsl:choose>
      <xsl:when test='ancestor::r:title'>
        <code class='elem-name'>&lt;<xsl:apply-templates/>&gt;</code>
      </xsl:when>
      <xsl:otherwise>
        <a href='#elem-{text()}' class='elem-name'>&lt;<xsl:apply-templates/>&gt;</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='r:pi'>
    <xsl:choose>
      <xsl:when test='ancestor::r:title'>
        <code class='pi-name'>&lt;?<xsl:apply-templates/>?&gt;</code>
      </xsl:when>
      <xsl:otherwise>
        <a href='#pi-{text()}' class='pi-name'>&lt;?<xsl:apply-templates/>?&gt;</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='r:bibliography'>
    <dl class='bibliography'>
      <xsl:apply-templates>
        <xsl:sort select='@xml:id'/>
      </xsl:apply-templates>
    </dl>
  </xsl:template>

  <xsl:template match='r:bibentry'>
    <dt id='{@xml:id}'><xsl:value-of select='@xml:id'/></dt>
    <xsl:for-each select='r:p'>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </xsl:for-each>
    <dd>
      <xsl:choose>
        <xsl:when test='r:entry'>
          <ul>
            <xsl:for-each select='r:entry'>
              <li><xsl:call-template name='bibentry'/></li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name='bibentry'/>
        </xsl:otherwise>
      </xsl:choose>
    </dd>
  </xsl:template>

  <xsl:template name='bibentry'>
    <cite><a href='{r:link}'><xsl:value-of select='r:title'/></a></cite>,
    <xsl:for-each select='r:authors/r:person'>
      <xsl:call-template name='display-person'>
        <xsl:with-param name='p' select='.'/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test='position() = last() - 1'><xsl:text>, and </xsl:text></xsl:when>
        <xsl:when test='position() = last()'><xsl:text>.</xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='r:ednote'>
    <div class='ednote'>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match='processing-instruction("respec-toc")'>
    <xsl:call-template name='table-of-content'/>
    <xsl:if test='/r:*/r:section[@type="appendix"]'>
      <xsl:call-template name='table-of-appendices'/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match='r:schema[.//rng:*]'>
    <div class='boxed'>
      <p><span class='schemaTitle'><xsl:value-of select='r:title'/></span></p>
      <pre class='schema' title='{r:title}'>
        <xsl:copy-of select='*[namespace-uri() != "http://berjon.com/ns/re-spec/"]'/>
      </pre>
    </div>
  </xsl:template>

  <xsl:template match='r:schema[.//r:idl]'>
    <div class='boxed'>
      <p><span class='idlTitle'><xsl:value-of select='r:title'/></span></p>
      <pre class='schema' title='{r:title}'>
        <xsl:apply-templates select='r:idl'/>
      </pre>
    </div>
  </xsl:template>

  <xsl:template match='r:schema[./r:ebnf]'>
    <div class='boxed'>
      <p><span class='ebnfTitle'><xsl:value-of select='r:title'/></span></p>
      <pre class='ebnf' title='{r:title}'>
        <xsl:apply-templates select='r:ebnf'/>
      </pre>
    </div>
  </xsl:template>

  <xsl:template match='r:ebnf'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='r:idl'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='r:example'>
    <div class='boxed'>
      <div><span class='exampleTitle'>Example: <xsl:value-of select='r:title'/></span></div>
      <pre class='example' title='{r:title}'>
        <xsl:copy-of select='*[namespace-uri() != "http://berjon.com/ns/re-spec/"]|text()'/>
      </pre>
    </div>
  </xsl:template>

  <xsl:template match='r:specexample'>
    <div class='boxed'>
      <div class='specexample'>
        <xsl:apply-templates />
      </div>
    </div>
  </xsl:template>

  <!-- **********************************************************************
      IDL-specific templates
  -->
  <xsl:template match='r:schema[.//r:idl[.//r:*]]'>
    <div class='boxed'>
      <p><span class='idlTitle'><xsl:value-of select='r:title'/></span></p>
      <pre class='schema' title='{r:title}'>
        <xsl:apply-templates select='r:idl'/>
      </pre>
    </div>
  </xsl:template>

  <xsl:template match='r:interface'>
    <div class='section'>
      <xsl:apply-templates select='r:definition-group'/>

      <xsl:if test='r:attribute'>
        <div class='section'>
          <h4 class='idl-header'>Attributes</h4>
          <dl class='idl-attr'>
            <xsl:apply-templates select='r:attribute'>
              <xsl:sort select='@name'/>
            </xsl:apply-templates>
          </dl>
        </div>
      </xsl:if>

      <xsl:if test='r:method'>
        <div class='section'>
          <h4 class='idl-header'>Methods</h4>
          <dl class='idl-meth'>
            <xsl:apply-templates select='r:method'>
              <xsl:sort select='@name'/>
            </xsl:apply-templates>
          </dl>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match='r:attribute'>
    <xsl:variable name='type'>
      <xsl:choose>
        <xsl:when test='@type'><xsl:value-of select='@type'/></xsl:when>
        <xsl:otherwise>DOMString</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <dt id='idl-attr-{../@name}-{@name}'>
      <code><xsl:value-of select='@name'/></code>
      of type
      <xsl:choose>
        <xsl:when test='//r:interface[@name = $type]'><a href='#idl-if-{$type}'><xsl:value-of select='$type'/></a></xsl:when>
        <xsl:otherwise><xsl:value-of select='$type'/></xsl:otherwise>
      </xsl:choose>
      <xsl:if test='@ro = "true"'>, readonly</xsl:if>
    </dt>
    <dd>
      <xsl:apply-templates select='*[not(self::r:exception)]'/>
      <xsl:if test='r:exception'>
        <dl>
          <xsl:if test='contains(r:exception/r:code/@on, "setting")'>
            <dt>Exceptions on setting</dt>
            <dd>
              <table class='idl-exceptions'>
                <xsl:apply-templates select='r:exception[r:code[contains(@on, "setting")]]'/>
              </table>
            </dd>
          </xsl:if>
          <xsl:if test='contains(r:exception/r:code/@on, "retrieval")'>
            <dt>Exceptions on retrieval</dt>
            <dd>
              <table class='idl-exceptions'>
                <xsl:apply-templates select='r:exception[r:code[contains(@on, "retrieval")]]'/>
              </table>
            </dd>
          </xsl:if>
        </dl>
      </xsl:if>
    </dd>
  </xsl:template>

  <xsl:template match='r:definition-group'>
    <div class='section'>
      <h4 class='idl-header' id='idl-defs-{@for}'>Definition Group <em><xsl:value-of select='@for'/></em></h4>
      <xsl:apply-templates select='*[not(self::r:constant)]'/>
      <dl class='idl-defs'>
        <xsl:apply-templates select='r:constant'/>
      </dl>
    </div>
  </xsl:template>

  <xsl:template match='r:constant'>
    <dt id='idl-defs-{../@for}-{@name}'><code><xsl:value-of select='@name'/></code></dt>
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <xsl:template match='r:exception[r:code]'>
    <tr>
      <td>
        <xsl:choose>
          <xsl:when test='//r:exception[@name = current()/@name]'><a href='#idl-if-{@name}'><xsl:value-of select='@name'/></a></xsl:when>
          <xsl:otherwise><xsl:value-of select='@name'/></xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <table>
          <xsl:apply-templates/>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match='r:code[parent::r:exception]'>
    <tr>
      <td><xsl:value-of select='@name'/></td>
      <td><xsl:apply-templates/></td>
    </tr>
  </xsl:template>

  <xsl:template match='r:method'>
    <dt id='idl-meth-{../@name}-{@name}'><code><xsl:value-of select='@name'/></code></dt>
    <dd>
      <xsl:apply-templates select='*[not(self::r:param) and not(self::r:returns) and not(self::r:exception)]'/>
      <dl>
        <xsl:choose>
          <xsl:when test='r:param'>
            <dt>Parameters</dt>
            <dd class='idl-params'>
              <dl>
                <xsl:apply-templates select='r:param'/>
              </dl>
            </dd>
          </xsl:when>
          <xsl:otherwise><dt>No Parameters</dt></xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test='r:returns'>
            <dt>Return Value</dt>
            <dd>
              <dl>
                <table>
                  <tr>
                    <td><code><xsl:value-of select='@type'/></code></td>
                    <td>
                      <xsl:apply-templates select='r:returns/node()'/>
                    </td>
                  </tr>
                </table>
              </dl>
            </dd>
          </xsl:when>
          <xsl:otherwise><dt>No Return Value</dt></xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test='r:exception'>
            <dt>Exceptions</dt>
            <dd>
              <table>
                <xsl:apply-templates select='r:exception'/>
              </table>
            </dd>
          </xsl:when>
          <xsl:otherwise><dt>No Exceptions</dt></xsl:otherwise>
        </xsl:choose>
      </dl>
    </dd>
  </xsl:template>

  <xsl:template match='r:param'>
    <xsl:variable name='type'>
      <xsl:choose>
        <xsl:when test='@type'><xsl:value-of select='@type'/></xsl:when>
        <xsl:otherwise>DOMString</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <dt>
      <code><xsl:value-of select='@name'/></code>
      <xsl:choose>
        <xsl:when test='contains($type, "|")'>
          of varying types (see IDL)
        </xsl:when>
        <xsl:otherwise>
          of type
          <xsl:choose>
            <xsl:when test='//r:interface[@name = $type]'><a href='#idl-if-{$type}'><xsl:value-of select='$type'/></a></xsl:when>
            <xsl:otherwise><xsl:value-of select='$type'/></xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test='@optional = "true"'>, optional</xsl:if>
    </dt>
    <dd>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <xsl:template match='r:exception'>
    <!-- 
      there seems to never be anything described for this in the DOM
      specs, but we might want to change that
      -->
  </xsl:template>


  <!-- **********************************************************************
      reusable templates
  -->
  <xsl:template name='display-person'>
    <xsl:param name='p'/>
    <span class='person'>
      <xsl:choose>
        <xsl:when test='$p/r:url'>
          <a href='{$p/r:url}'><xsl:value-of select='$p/r:name'/></a>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select='$p/r:name'/></xsl:otherwise>
      </xsl:choose>
      <xsl:if test='$p/r:company'>
        <xsl:text> (</xsl:text>
	      <xsl:choose>
	        <xsl:when test='$p/r:company-url'>
	          <a href='{$p/r:company-url}'><xsl:value-of select='$p/r:company'/></a>
	        </xsl:when>
	        <xsl:otherwise><xsl:value-of select='$p/r:company'/></xsl:otherwise>
	      </xsl:choose>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test='$p/r:email'>
        <xsl:text> &lt;</xsl:text>
        <a href='mailto:{$p/r:email}'><xsl:value-of select='$p/r:email'/></a>
        <xsl:text>></xsl:text>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template name='table-of-content'>
    <xsl:param name='ctx' select='/r:*'/>
    <ul class='toc'>
      <xsl:for-each select='$ctx/r:section[not($noTOC/@key = @type)]'>
        <li>
          <a href='#{@xml:id}'>
            <xsl:call-template name='get-section-number'>
              <xsl:with-param name='section' select='.'/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select='r:title/node()'/>
          </a>
        </li>
        <xsl:if test='./r:section'>
          <li>
            <xsl:call-template name='table-of-content'>
              <xsl:with-param name='ctx' select='.'/>
            </xsl:call-template>
          </li>
        </xsl:if>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name='get-section-number'>
    <xsl:param name='section'/>
    <xsl:for-each select='ancestor-or-self::r:section'>
      <xsl:value-of select='count(preceding-sibling::r:section[not($noTOC/@key = @type)]) + 1'/>
      <xsl:text>.</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name='table-of-appendices'>
    <ul class='toc'>
      <xsl:for-each select='/r:*/r:section[@type = "appendix"]'>
        <li>
          <a href='#{@xml:id}'>
            <xsl:number format='A' value='count(preceding-sibling::r:section[@type = "appendix"]) + 1'/>
            <xsl:text>. </xsl:text>
            <xsl:apply-templates select='r:title/node()'/>
          </a>
        </li>
        <!--
          We don't currently descend into subsections of appendices
        -->
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- **********************************************************************
      spec type specific templates
  -->
  <xsl:template name='type-specific-header'>
    <xsl:message>No 'type-specific-header' template in XSLT.</xsl:message>
  </xsl:template>

  <xsl:template name='type-specific-body'>
    <xsl:message>No 'type-specific-body' template in XSLT.</xsl:message>
  </xsl:template>

  <xsl:template name='type-specific-footer'>
    <xsl:message>No 'type-specific-footer' template in XSLT.</xsl:message>
  </xsl:template>


  <!-- **********************************************************************
      elements that produce no output
  -->
  <xsl:template match='r:metadata'/>
  <xsl:template match='r:title'/>

  <!-- **********************************************************************
      warnings
  -->
  <xsl:template match='r:*'>
    <xsl:message>Unknown element 'r:<xsl:value-of select='local-name()'/>', skipping.</xsl:message>
  </xsl:template>

  <xsl:template match='*'>
    <xsl:message>
      <xsl:text>Unknown element '{</xsl:text>
      <xsl:value-of select='namespace-uri()'/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select='local-name()'/>
      <xsl:text>', skipping.</xsl:text>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
