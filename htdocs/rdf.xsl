<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:rss="http://purl.org/rss/1.0/"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  exclude-result-prefixes="rdf rss dc content">

  <xsl:output method="html" />

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="rdf:RDF">
    <html xml:lang="ja" lang="ja">
    <head>
      <title>RSS from <xsl:value-of select="/rdf:RDF/rss:channel/rss:title"/></title>
      <meta http-equiv="Content-Style-Type" conent="text/css"/>
    </head>
    <body>
      <h2><a>
        <xsl:attribute name="href">
          <xsl:value-of select="//rss:link"/>
        </xsl:attribute><xsl:value-of select="//rss:title"/>
      </a></h2>
      <p>
        <!--<a>
          <xsl:attribute name="href">
            <xsl:value-of select="//rss:link"/>
          </xsl:attribute>
          <xsl:value-of select="//rss:title"/>
        </a>-->
        最終更新日：<xsl:value-of select="//dc:date"/>
      </p>
      <hr color="orange"/>
      <xsl:apply-templates select="rss:item"/>
    </body>
    </html>
  </xsl:template>

  <xsl:template match="rss:item">
    <div bgcolor="red">
          <h2>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="rss:link"/>
            </xsl:attribute>
            <xsl:value-of select="rss:title"/>
          </a>
          </h2>
          <!-- <pre><xsl:value-of select="rss:description"/></pre> -->
         <xsl:value-of select="content:encoded" disable-output-escaping="yes"/>
      <hr color="orange"/>
    </div>
  </xsl:template>
</xsl:stylesheet>
