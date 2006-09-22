<xsl:stylesheet
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns='http://www.w3.org/1999/xhtml'
                xmlns:r='http://berjon.com/ns/re-spec/'
                xmlns:c='http://berjon.com/ns/xslt-conf/'
                exclude-result-prefixes='r c'
                version='1.0'>

  <xsl:import href='Re-Spec-xhtml.xslt'/>

  <status xmlns='http://berjon.com/ns/xslt-conf/'>
    <!-- add others as needed -->
    <item key='ED'   style='base'>W3C Editor's Draft</item>
    <item key='PUB'  style='base'>W3C Public Working Group Document</item>
    <item key='EDMO' style='W3C-MO'>W3C Editor's Draft</item>
    <item key='N'    style='W3C-WG-NOTE'>W3C Working Group Note</item>
    <item key='INF'  style='W3C-MO'>Informal Document</item>
    <item key='MO'   style='W3C-MO'>W3C Member Only Document</item>
    <item key='WD'   style='W3C-WD'>W3C Working Draft</item>
    <item key='LC'   style='W3C-WD'>W3C Last Call Working Draft</item>
    <item key='CR'   style='W3C-CR'>W3C Candidate Recommendation</item>
    <item key='PR'   style='W3C-PR'>W3C Proposed Recommendation</item>
    <item key='REC'  style='W3C-REC'>W3C Rescinded Recommendation</item>
  </status>

  <xsl:output
              method='xml'
              media-type='application/xhtml+xml'
              encoding='UTF-8'
              indent='yes'
              doctype-public='-//W3C//DTD XHTML 1.0 Strict//EN'
              doctype-system='http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
              />
    
  <xsl:variable name='statusConf' select='document("")//c:status/c:item[@key = $specStatus]'/>
  <xsl:variable name='specVersions' select='/r:*/r:metadata/r:versions'/>

  <xsl:template name='type-specific-header'>
    <link rel='stylesheet' href='respec:respec-w3c.css' type='text/css'/>
    <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/{$statusConf/@style}' type='text/css'/>
    <meta name='revision' content='$Id: W3C-xhtml.xslt,v 1.2 2006-09-22 12:36:30 rberjon Exp $' />
  </xsl:template>

  <xsl:template name='type-specific-body'>
    <div class="head">
      <p>
        <a href="http://www.w3.org/"><img src="http://www.w3.org/Icons/w3c_home" width="72" height="48" alt="W3C"/></a>
      </p>

      <h1 class='head'><xsl:value-of select='$title'/></h1>

      <!-- the date will need some formatting munging in real life -->
      <h2 id='pagesubtitle'><xsl:value-of select='$statusConf/text()'/><xsl:text> </xsl:text>
                            <em><xsl:value-of select='$humanDate'/></em></h2>

      <dl>
        <xsl:if test='$specVersions/r:current'>
          <dt>This version:</dt>
          <dd><a href='{$specVersions/r:current}'><xsl:value-of select='$specVersions/r:current'/></a></dd>
        </xsl:if>

        <xsl:if test='$specVersions/r:latest'>
          <dt>Latest version:</dt>
          <dd><a href='{$specVersions/r:latest}'><xsl:value-of select='$specVersions/r:latest'/></a></dd>
        </xsl:if>

        <xsl:if test='$specVersions/r:previous'>
          <dt>Previous version:</dt>
          <dd><a href='{$specVersions/r:previous}'><xsl:value-of select='$specVersions/r:previous'/></a></dd>
        </xsl:if>
        <dt>
          <xsl:choose>
            <xsl:when test='count($editors) = 1'>Editor:</xsl:when>
            <xsl:otherwise>Editors:</xsl:otherwise>
          </xsl:choose>
        </dt>
        <xsl:for-each select='$editors'>
          <dd>
            <xsl:call-template name='display-person'>
              <xsl:with-param name='p' select='.'/>
            </xsl:call-template>
          </dd>
        </xsl:for-each>
      </dl>


      <p class='copyright'>
        <a href='http://www.w3.org/Consortium/Legal/ipr-notice#Copyright'>Copyright</a> ©2006
        <a href='http://www.w3.org/'><acronym title='World Wide Web Consortium'>W3C</acronym></a><sup>®</sup>
        (<a href='http://www.csail.mit.edu/'><acronym title='Massachusetts Institute of Technology'>MIT</acronym></a>,
        <a href='http://www.ercim.org/'><acronym title='European Research Consortium for Informatics and Mathematics'>ERCIM</acronym></a>,
        <a href='http://www.keio.ac.jp/'>Keio</a>), All Rights Reserved. W3C
        <a href='http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer'>liability</a>,
        <a href='http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks'>trademark</a> and 
        <a href='http://www.w3.org/Consortium/Legal/copyright-documents'>document  use</a> rules apply.
      </p>
    </div>
    <hr/>
  </xsl:template>

  <xsl:template name='type-specific-footer'>
    <!--
        @@
        something quite simple
    -->
  </xsl:template>


  <!-- *********************************************************
        Overrides
  -->
  <xsl:template match='r:dl[@type = "attr-list"]'>
    <h4 class='attrlist' id='attr-list-{ancestor::r:section[1]/@xml:id}'>Attributes list</h4>
    <dl class='attrlist'>
      <xsl:apply-templates/>
    </dl>
  </xsl:template>

  <xsl:template match='r:section[@type="w3c-abstract"]'>
    <h2 id='specabstract'>Abstract</h2>
    <div class='section'>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


</xsl:stylesheet>
