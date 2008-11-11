<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:h='http://www.w3.org/1999/xhtml'
                xmlns='http://www.w3.org/1999/xhtml'
                xmlns:date="http://exslt.org/dates-and-times"
                exclude-result-prefixes='h date'
                version='1.0' id='xslt'>

  <xsl:output method='xml' encoding='us-ascii'
              doctype-public='-//W3C//DTD XHTML 1.0 Strict//EN'
              doctype-system='http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
              media-type='application/xhtml+xml; charset=us-ascii'
              indent="yes"
              />

  <xsl:variable name='sectionsID'>this_sections</xsl:variable>
  <xsl:variable name='appendicesID'>appendices</xsl:variable>

  <xsl:variable name='id' select='/*/h:head/h:meta[@name="revision"]/@content'/>
  <xsl:variable name='rev' select='substring-before(substring-after(substring-after($id, " "), " "), " ")'/>
  <xsl:variable name='toc-marker' select='//h:*[@id = "toc"][1]'/>
  <xsl:variable name='info' select="/*/h:body/h:*[@id = 'info']"/>
  <xsl:variable name="maturity" select="$info/h:*[@id = 'maturity']"/>
  <xsl:variable name="source" select="$info/h:*[@id = 'versions']/h:*[@id = 'source']"/>
  <xsl:variable name="this" select="$info/h:*[@id = 'versions']/h:*[@id = 'this']"/>
  <xsl:variable name="latest" select="$info/h:*[@id = 'versions']/h:*[@id = 'latest']"/>
  <xsl:variable name="previous-nodeset" select="$info/h:*[@id = 'versions']/h:*[contains(@class,'previous')]"/>
  <xsl:variable name="person-nodeset" select='$info/h:*[@id="editors"]/h:*[@ class="person"]'/>
  <xsl:variable name="prev-person-nodeset" select='$info/h:*[@id="prev_editors"]/h:*[@ class="person"]'/>
  <xsl:variable name="groupinfo-nodeset" select="$info/h:*[@id = 'groupinfo']"/>

  <xsl:template match='/'>
    <xsl:if test='$maturity = "ED"'>
      <xsl:comment> * </xsl:comment>
      <xsl:comment> * Note: This file was generated from source at <xsl:value-of select="$source"/><xsl:text> </xsl:text></xsl:comment>
      <xsl:comment> * Run the "make" command to regenerate it. </xsl:comment>
      <xsl:comment> * </xsl:comment>
    </xsl:if>
    <xsl:apply-templates select='/*'/>
  </xsl:template>

  <xsl:template match='h:*'>
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='h:head'>
    <head>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
      <xsl:text>  </xsl:text>
      <xsl:choose>
        <xsl:when test="$maturity = 'ED'">
          <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/W3C-ED' type='text/css'/>
        </xsl:when>
        <xsl:when test='
          $maturity="WD"
          or $maturity="FPWD"
          or $maturity="LCWD"
          or $maturity="FPWDLC"
          '>
          <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/W3C-WD' type='text/css'/>
        </xsl:when>
        <xsl:otherwise>
          <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/W3C-{$maturity}' type='text/css'/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;  </xsl:text>
    </head>
  </xsl:template>

  <!-- * suppress meta@charset -->
  <xsl:template match="h:meta[@charset]"/>
  <!-- * suppress duplication of ED CSS link -->
  <xsl:template match="h:head/h:link[@href = 'http://www.w3.org/StyleSheets/TR/W3C-ED']"/>
  <!-- * remove source CSS link -->
  <xsl:template match="h:head/h:link[@href = 'src.css']"/>
  <!-- * remove info stuff -->
  <xsl:template match="h:*[@id = 'info']"/>
  <!-- * remove source admonition -->
  <xsl:template match="*[@id = 'source-admonition']" priority="10"/>

  <xsl:template name='monthName'>
    <xsl:param name='n' select='1'/>
    <xsl:param name='s' select='"January February March April May June July August September October November December "'/>
    <xsl:choose>
      <xsl:when test='string(number($n))="NaN"'>@@</xsl:when>
      <xsl:when test='$n = 1'>
        <xsl:value-of select='substring-before($s, " ")'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name='monthName'>
          <xsl:with-param name='n' select='$n - 1'/>
          <xsl:with-param name='s' select='substring-after($s, " ")'/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="h:body">
    <body>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:call-template name="top"/>
      <xsl:apply-templates/>
    </body>
  </xsl:template>

  <xsl:template name='top'>
    <div class='head'>
      <div><a href="http://www.w3.org/"><img src="http://www.w3.org/Icons/w3c_home" width="72" height="48" alt="W3C"></img></a></div>
      <h1><xsl:value-of select='/*/h:head/h:title'/></h1>
      <xsl:if test='//*[@id="subtitle"]'>
        <h3 id="subtitle"><xsl:value-of select='//*[@id="subtitle"]'/></h3>
      </xsl:if>
      <h2>
        W3C
        <xsl:choose>
          <xsl:when test='
            $maturity="WD"
            or $maturity="FPWD"
            or $maturity="LCWD"
            or $maturity="FPWDLC"
            '>Working Draft</xsl:when>
          <xsl:when test='$maturity="CR"'>Candidate Recommendation</xsl:when>
          <xsl:when test='$maturity="PR"'>Proposed Recommendation</xsl:when>
          <xsl:when test='$maturity="PER"'>Proposed Edited Recommendation</xsl:when>
          <xsl:when test='$maturity="REC"'>Recommendation</xsl:when>
          <xsl:when test='$maturity="WG-NOTE"'>Working Group Note</xsl:when>
          <xsl:otherwise>Editor’s Draft</xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <em>
          <xsl:call-template name='date'/>
        </em>
      </h2>

      <dl>
        <xsl:choose>
          <xsl:when test='$source and $maturity="ED"'>
            <dt>Latest Editor’s Draft:</dt>
            <dd>
              <a id='latestED' href='{$source}'><xsl:value-of select='$source'/></a>
              <xsl:text> </xsl:text>
            </dd>
            <xsl:if test='$latest and not($latest = "")'>
              <dt>Latest Published Version:</dt>
              <dd><a href='{$latest}'><xsl:value-of select='$latest'/></a></dd>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <dt>This Version:</dt>
            <dd>
              <a href='{$this}'><xsl:value-of select='$this'/></a>
            </dd>
            <xsl:if test='not($latest = "")'>
              <dt>Latest Version:</dt>
              <dd><a href='{$latest}'><xsl:value-of select='$latest'/></a></dd>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test='$previous-nodeset
          and not($previous-nodeset = "")'>
          <dt>Previous Version<xsl:if test='count($previous-nodeset) > 1'>s</xsl:if>:</dt>
          <xsl:for-each select='$previous-nodeset'>
            <dd><a href='{.}'><xsl:value-of select='.'/></a></dd>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="$person-nodeset">
          <dt>Editor<xsl:if test='count($person-nodeset) &gt; 1'>s</xsl:if>:</dt>
          <xsl:for-each select='$person-nodeset'>
            <dd>
              <xsl:choose>
                <xsl:when test='h:*[contains(@class,"homepage")]'>
                  <a href='{h:*[contains(@class,"homepage")]}'><xsl:value-of select='h:span[@class = "name"]'/></a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select='h:span[@class = "name"]'/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test='h:span[@class = "affiliation"]'>
                <xsl:text>, </xsl:text>
                <xsl:value-of select='h:span[@class = "affiliation"]'/>
              </xsl:if>
              <xsl:if test='h:*[contains(@class,"email")]'>
                <xsl:text> &lt;</xsl:text>
                <a href='mailto:{h:*[contains(@class,"email")]}'><xsl:value-of select='h:*[contains(@class,"email")]'/></a>
                <xsl:text>&gt;</xsl:text>
              </xsl:if>
            </dd>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="$prev-person-nodeset">
          <dt>Previous Editor<xsl:if test='count($prev-person-nodeset) &gt; 1'>s</xsl:if>:</dt>
          <xsl:for-each select='$prev-person-nodeset'>
            <dd>
              <xsl:choose>
                <xsl:when test='h:*[contains(@class,"homepage")]'>
                  <a href='{h:*[contains(@class,"homepage")]}'><xsl:value-of select='h:span[@class = "name"]'/></a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select='h:span[@class = "name"]'/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test='h:span[@class = "affiliation"]'>
                <xsl:text>, </xsl:text>
                <xsl:value-of select='h:span[@class = "affiliation"]'/>
              </xsl:if>
              <xsl:if test='h:*[contains(@class,"email")]'>
                <xsl:text> &lt;</xsl:text>
                <a href='mailto:{h:*[contains(@class,"email")]}'><xsl:value-of select='h:*[contains(@class,"email")]'/></a>
                <xsl:text>&gt;</xsl:text>
              </xsl:if>
            </dd>
          </xsl:for-each>
        </xsl:if>
      </dl>
      <p class="copyright"><a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a><xsl:text disable-output-escaping='yes'> &amp;copy; </xsl:text><xsl:value-of select='concat(substring($this, string-length($this) - 8, 4), " ")'/><a href="http://www.w3.org/"><acronym title="World Wide Web Consortium">W3C</acronym></a><sup><xsl:text disable-output-escaping='yes'>&amp;reg;</xsl:text></sup> (<a href="http://www.csail.mit.edu/"><acronym title="Massachusetts Institute of Technology">MIT</acronym></a>, <a href="http://www.ercim.org/"><acronym title="European Research Consortium for Informatics and Mathematics">ERCIM</acronym></a>, <a href="http://www.keio.ac.jp/">Keio</a>), All Rights Reserved. W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p>
    </div>
    <hr/>
  </xsl:template>

  <xsl:template name='date'>
    <xsl:variable name='date'>
      <xsl:value-of select='substring($this, string-length($this) - 8, 8)'/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test='$maturity="ED"'>
        <xsl:value-of select="date:day-in-month()"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="date:month-name()"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="date:year()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='number(substring($date, 7))'/>
        <xsl:text> </xsl:text>
        <xsl:call-template name='monthName'>
          <xsl:with-param name='n' select='number(substring($date, 5, 2))'/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select='substring($date, 1, 4)'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name='maturity'>
    <xsl:choose>
      <xsl:when test='$maturity="FPWD"'>First Public Working Draft</xsl:when>
      <xsl:when test='$maturity="LCWD"'>Last Call Working Draft</xsl:when>
      <xsl:when test='$maturity="FPWDLC"'>First Public Working Draft and Last Call Working Draft</xsl:when>
      <xsl:when test='$maturity="WD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="CR"'>Candidate Recommendation</xsl:when>
      <xsl:when test='$maturity="PR"'>Proposed Recommendation</xsl:when>
      <xsl:when test='$maturity="PER"'>Proposed Edited Recommendation</xsl:when>
      <xsl:when test='$maturity="REC"'>Recommendation</xsl:when>
      <xsl:when test='$maturity="WG-NOTE"'>Working Group Note</xsl:when>
      <xsl:otherwise>Editor’s Draft</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name='maturity-short'>
    <xsl:choose>
      <xsl:when test='$maturity="FPWD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="LCWD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="FPWDLC"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="WD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="CR"'>Candidate Recommendation</xsl:when>
      <xsl:when test='$maturity="PR"'>Proposed Recommendation</xsl:when>
      <xsl:when test='$maturity="PER"'>Proposed Edited Recommendation</xsl:when>
      <xsl:when test='$maturity="REC"'>Recommendation</xsl:when>
      <xsl:when test='$maturity="WG-NOTE"'>Working Group Note</xsl:when>
      <xsl:otherwise>Editor’s Draft</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="h:*[@id = 'abstract']">
    <div id="abstract">
      <xsl:apply-templates/>
      <!-- * <xsl:call-template name="revision-note"/> -->
    </div>
  </xsl:template>

  <xsl:template name='revision-note'>
    <xsl:if test='$maturity="ED"'>
      <div class='ednote'>
        <h4 class='ednoteHeader'>Editorial note</h4>
        <p>This document was generated on
          <b><xsl:value-of select='date:date-time()'/></b>.</p>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="h:*[@id = 'status']">
    <div>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
      <xsl:call-template name="sotd"/>
    </div>
  </xsl:template>

  <xsl:template name='sotd'>
    <xsl:variable name='w3c-ipp' select='$groupinfo-nodeset/*[@id = "w3c-ipp"]'/>
    <xsl:variable name='comments-address' select='$groupinfo-nodeset/*[@id = "comments-address"]'/>
    <xsl:variable name='comments-archive' select='$groupinfo-nodeset/*[@id = "comments-archive"]'/>
    <xsl:variable name='group-url' select='$groupinfo-nodeset/*[@id = "group-url"]'/>
    <xsl:variable name='group-name' select='$groupinfo-nodeset/*[@id = "group-name"]'/>
    <!-- * <xsl:variable name="activity"> -->
      <!-- * <a href="{$groupinfo-nodeset/*[@id = 'activity']}"> -->
        <!-- * <xsl:choose> -->
          <!-- * <xsl:when test="$groupinfo-nodeset/*[@id = 'activity'] = 'http://www.w3.org/MarkUp/Activity.html'" -->
            <!-- * >HTML Activity</xsl:when> -->
          <!-- * <xsl:otherwise>[undefined activity]</xsl:otherwise> -->
        <!-- * </xsl:choose> -->
      <!-- * </a> -->
    <!-- * </xsl:variable> -->
    <!-- * <xsl:variable name="domain"> -->
      <!-- * <a href="{$groupinfo-nodeset/*[@id = 'domain']}"> -->
        <!-- * <xsl:choose> -->
          <!-- * <xsl:when test="$groupinfo-nodeset/*[@id = 'domain'] = 'http://www.w3.org/Interaction/'" -->
            <!-- * >Interaction Domain</xsl:when> -->
          <!-- * <xsl:otherwise>[undefined domain]</xsl:otherwise> -->
        <!-- * </xsl:choose> -->
      <!-- * </a> -->
    <!-- * </xsl:variable> -->
    <xsl:variable name="source">
      <a href="{$source}">group’s source repository</a>
    </xsl:variable>
    <xsl:text>&#10;    </xsl:text>
    <p>
      <em>
        This section describes the status of this document at the time of
        its publication.  Other documents may supersede this document. A list
        of current W3C publications and the latest revision of this technical
        report can be found in the <a href="http://www.w3.org/TR/">W3C technical
          reports index</a> at http://www.w3.org/TR/.
      </em>
    </p>
    <xsl:text>&#10;    </xsl:text>
    <p>
      <xsl:if test='$maturity!="REC" and $maturity!="WG-NOTE"'>
        This document is the <xsl:call-template name='date'/><xsl:text> </xsl:text>
        <xsl:call-template name='maturity'/> of 
        <cite><xsl:value-of select='/*/h:head/h:title'/></cite>.
      </xsl:if>
      Please send comments about this document to
      <a href='mailto:{$comments-address}'><xsl:value-of select='$comments-address'/></a>
      (<a href='{$comments-archive}'>archived</a>).
    </p>
    <xsl:text>&#10;    </xsl:text>
    <p>
      This document
      <xsl:choose>
        <xsl:when test="$maturity='ED'">
          <xsl:text> is associated with </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> was produced by </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      the <a href="{$group-url}"
        ><xsl:copy-of select="normalize-space($group-name)"/></a>.
      <!-- * part of the <xsl:copy-of select="$activity"/> -->
      <!-- * in the W3C <xsl:copy-of select="$domain"/>. -->
      You can find the source for the current version of this document in the
      <xsl:copy-of select="$source"/>.
    </p>
    <xsl:text>&#10;    </xsl:text>
    <xsl:copy-of select="//*[@id='status']/*[not(local-name() = 'h2')]"/>
    <xsl:text>&#10;    </xsl:text>
    <p>
      <xsl:choose>
        <xsl:when test='$maturity="REC"'>
          This document has been reviewed by W3C Members, by software developers,
          and by other W3C groups and interested parties, and is endorsed by the
          Director as a W3C Recommendation. It is a stable document and may be
          used as reference material or cited from another document. W3C’s role
          in making the Recommendation is to draw attention to the specification
          and to promote its widespread deployment. This enhances the
          functionality and interoperability of the Web.
        </xsl:when>
        <xsl:otherwise>
          Publication as
          <xsl:choose>
            <xsl:when test='$maturity = "ED"'>
              <xsl:text>an</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>a</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> </xsl:text>
          <xsl:call-template name='maturity-short'/> does not imply endorsement by the
          W3C Membership.  This is a draft document and may be updated, replaced
          or obsoleted by other documents at any time. It is inappropriate to cite
          this document as other than work in progress.
        </xsl:otherwise>
      </xsl:choose>
    </p>
    <xsl:text>&#10;    </xsl:text>
    <xsl:if test="not($maturity='ED')">
      <p>
        This document was produced by a group operating under the
        <a href='http://www.w3.org/Consortium/Patent-Policy-20040205/'>5 February
          2004 W3C Patent Policy</a>. W3C maintains a
        <a href='{$w3c-ipp}'>public list of
          any patent disclosures</a> made in connection with the deliverables of
        the group; that page also includes instructions for disclosing a patent.
        An individual who has actual knowledge of a patent which the individual
        believes contains
        <a href='http://www.w3.org/Consortium/Patent-Policy-20040205/#def-essential'>Essential
          Claim(s)</a> must disclose the information in accordance with
        <a href='http://www.w3.org/Consortium/Patent-Policy-20040205/#sec-Disclosure'>section
          6 of the W3C Patent Policy</a>.
      </p>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="h:*[@id = 'toc']">
    <xsl:text>&#10;</xsl:text>
    <div id='toc'>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
      <xsl:call-template name="toc"/>
    </div>
  </xsl:template>

  <xsl:template name='toc'>
    <xsl:for-each select='//*[@id=$sectionsID]'>
      <xsl:call-template name='toc1'/>
    </xsl:for-each>
    <xsl:for-each select='//*[@id=$appendicesID]'>
      <xsl:call-template name='toc1'>
        <xsl:with-param name='alpha' select='true()'/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='processing-instruction("sref")'>
    <xsl:variable name='id' select='string(.)'/>
    <xsl:variable name='s' select='//*[@id=$id]/self::h:div[contains(@class,"section")]'/>
    <xsl:choose>
      <xsl:when test='$s'>
        <xsl:call-template name='section-number'>
          <xsl:with-param name='section' select='$s'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='processing-instruction("sdir")'>
    <xsl:variable name='id' select='string(.)'/>
    <xsl:choose>
      <xsl:when test='preceding::h:*[@id=$id]'>above</xsl:when>
      <xsl:when test='following::h:*[@id=$id]'>below</xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='processing-instruction()|comment()'/>

  <xsl:template name='toc1'>
    <xsl:param name='prefix'/>
    <xsl:param name='alpha'/>
    <xsl:variable name='subsections' select='h:div[contains(@class,"section")][not(contains(@class,"no-toc"))]'/>
    <xsl:if test='$subsections'>
      <ul>
      <xsl:text>&#10;</xsl:text>
        <xsl:for-each select='h:div[contains(@class,"section")][not(contains(@class,"no-toc"))]'>
          <xsl:variable name='number'>
            <xsl:value-of select='$prefix'/>
            <xsl:if test='$prefix'>.</xsl:if>
            <xsl:choose>
              <xsl:when test='$alpha'><xsl:number value='position()' format='A'/></xsl:when>
              <xsl:otherwise><xsl:value-of select='position()'/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name='frag'>
            <xsl:choose>
              <xsl:when test='@id'><xsl:value-of select='@id'/></xsl:when>
              <xsl:when test='h:h2/@id'>
                <xsl:value-of select='h:h2/@id'/>
              </xsl:when>
              <xsl:otherwise><xsl:value-of select='generate-id(.)'/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <li id='{$frag}-toc'>
            <a href='#{$frag}'>
              <xsl:if test="not(contains(@class,'no-number'))">
                <xsl:value-of select='$number'/>
                <xsl:text>. </xsl:text>
              </xsl:if>
              <xsl:copy-of select='(h:h2|h:h3|h:h4|h:h5|h:h6)/node()'/>
            </a>
            <xsl:if test='h:h2[@class = "element-head"]
              and .//*[@class = "obsolete"]'>
              <xsl:text> </xsl:text>
              <span class="obsolete">(obsolete)</span>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name='toc1'>
              <xsl:with-param name='prefix' select='$number'/>
            </xsl:call-template>
          </li>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
      </ul>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name='section-number'>
    <xsl:param name='section'/>
    <xsl:param name='sections' select="//*[@id = $sectionsID]"/>
    <xsl:param name='appendices' select="//*[@id = $appendicesID]"/>
    <xsl:choose>
      <xsl:when test='$section/ancestor::* = $sections'>
        <xsl:for-each
          select='$section/ancestor-or-self::h:div[contains(@class,"section")]'>
          <xsl:value-of select='count(preceding-sibling::h:div[contains(@class,"section")]) + 1'/>
          <xsl:if test='position() != last()'>
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test='$section/ancestor::* = $appendices'>
        <xsl:for-each select='$section/ancestor-or-self::h:div[contains(@class,"section")]'>
          <xsl:choose>
            <xsl:when test='position()=1'>
              <xsl:number value='count(preceding-sibling::h:div[contains(@class,"section")]) + 1' format='A'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='count(preceding-sibling::h:div[contains(@class,"section")]) + 1'/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test='position() != last()'>
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='h:h2[
    not(../@id = "abstract")
    and not(../@id="status")
    and not(../@id="toc")
    ]'
    >
    <xsl:variable name="myid">
      <xsl:choose>
        <xsl:when test="../@id">
          <xsl:value-of select="../@id"/>
        </xsl:when>
        <xsl:when test="@id">
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='generate-id(.)'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="id-adjusted">
      <xsl:value-of select="substring-before($myid, '_')"/>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:value-of
        select="concat(substring-before(ancestor-or-self::h:div[contains(@class,'section')][../../../h:*[@id = $sectionsID]]/@id, '_'),'.html')"/>
    </xsl:variable>
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:if test='$toc-marker
        and not(parent::h:*[contains(@class,"no-number")])'>
        <xsl:variable name='num'>
          <xsl:call-template name='section-number'>
            <xsl:with-param name='section' select='..'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test='$num != ""'>
          <xsl:value-of select='$num'/>
          <xsl:text>. </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select='node()'/>
      <xsl:if test='@class = "element-head"
        and parent::h:*//*[@class = "obsolete"]'>
        <xsl:text> </xsl:text>
        <span class="obsolete">(obsolete)</span>
      </xsl:if>
      <xsl:text> </xsl:text>
      <a class="hash" href="#{$myid}">#</a>
      <xsl:if test='not(parent::h:*[contains(@class,"no-toc")])'>
        <xsl:text> </xsl:text>
        <a class="toc-bak" href="#{$myid}-toc">T</a>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match='h:*[@class="ednote"]'>
    <div>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <div class='ednoteHeader'>Editorial note</div>
      <xsl:apply-templates select='node()'/>
    </div>
  </xsl:template>

  <!-- * <xsl:template match='h:*[@class="example"]'> -->
    <!-- * <div> -->
      <!-- * <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/> -->
      <!-- * <div class='exampleHeader'>Example</div> -->
      <!-- * <xsl:apply-templates select='node()'/> -->
    <!-- * </div> -->
  <!-- * </xsl:template> -->

  <!-- * <xsl:template match='h:*[@class="note"]'> -->
    <!-- * <div> -->
      <!-- * <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/> -->
      <!-- * <div class='noteHeader'>Note</div> -->
      <!-- * <xsl:apply-templates select='node()'/> -->
    <!-- * </div> -->
  <!-- * </xsl:template> -->

  <xsl:template match='h:div[contains(@class,"section")]'>
    <div>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:attribute name="class">section</xsl:attribute>
      <xsl:apply-templates select='node()'/>
    </div>
  </xsl:template>

  <xsl:template match='*'/>
</xsl:stylesheet>
