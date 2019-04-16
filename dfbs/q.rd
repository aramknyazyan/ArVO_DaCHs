<resource schema="dfbsplates" resdir="dfbs">
  <meta name="creationDate">2018-09-08T06:47:55Z</meta>

  <meta name="title">Digitized First Byurakan Survey (DFBS) Plate Scans</meta>

  <meta name="description" format="rst">
    The First Byurakan Survey (FBS) is the largest and the first systematic
    objective prism survey of the extragalactic sky. It covers 17,000 sq.deg.
    in the Northern sky together with a high galactic latitudes region in the
    Southern sky.   This service serves the scanned objective prism images.
  </meta>

  <meta name="subject">objective prism</meta>
  <meta name="subject">spectroscopy</meta>

  <meta name="creator">Markarian, B.E.; Lipovetski, V.A.; Stepanian, J.A.</meta>
  <meta name="instrument">Byurakan 1m Schmidt</meta>
  <meta name="facility">Byurakan Astrophysical Observatory BAO</meta>

  <meta name="source">2007A&amp;A...464.1177M</meta>
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>

  <meta name="coverage">
    <meta name="waveband">Optical</meta>
  </meta>

  <table id="main" onDisk="True" mixin="//siap#pgs" adql="True">
    <meta name="_associatedDatalinkService">
      <meta name="serviceId">dl</meta>
      <meta name="idColumn">publisher_did</meta>
    </meta>

    <mixin
      calibLevel="2"
      collectionName="'DFBS-plates'"
      expTime="exptime"
    >//obscore#publishSIAP</mixin>

    <column name="plate" type="text"
      ucd="meta.id"
      tablehead="Plate id"
      description="Identifier (plate number) for the DFBS plate."
      verbLevel="1"/>
    <column name="exptime"
      unit="s" ucd=""
      tablehead="Exptime"
      description="Exposure time."
      verbLevel="15"/>
     <column name="publisher_did" type="text"
      ucd="meta.ref.uri;meta.curation"
      description="Dataset identifier assigned by the publisher."
      verbLevel="25"/>
  </table>

  <coverage>
    <updater sourceTable="main"/>
  </coverage>

  <data id="import">
    <sources recurse="True">
      <pattern>data/*.fits</pattern>
      <pattern>data/*.FITS</pattern>
    </sources>

    <fitsProdGrammar>
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.data"</bind>
      </rowfilter>
    </fitsProdGrammar>

    <make table="main">
      <rowmaker>
        <apply procDef="//siap#setMeta">
          <bind key="dateObs">parseDate(@DATE_OBS)</bind>
          <bind key="bandpassId">@EMULSION</bind>
          <bind key="pixflags">"C"</bind>
          <bind key="title">"Byurakan %s (%s)"%(@PLATENUM, @EMULSION)</bind>
        </apply>

        <apply procDef="//siap#getBandFromFilter"/>

        <apply procDef="//siap#computePGS"/>

        <map key="plate" source="PLATENUM"/>
        <map key="exptime">@EXPTIME</map>
        <map key="publisher_did">\standardPubDID</map>
      </rowmaker>
    </make>
  </data>

  <service id="i" allowed="form,siap.xml">
    <meta name="description">First Byurakan survey plate scan service</meta>
    <meta name="shortName">DFBS plates</meta>
    <meta name="sia.type">Pointed</meta>
    <meta name="testQuery.pos.ra">28.394</meta>
    <meta name="testQuery.pos.dec">19.222</meta>
    <meta name="testQuery.size.ra">0.1</meta>
    <meta name="testQuery.size.dec">0.1</meta>

    <!-- <publish render="form,scs.xml" sets="ivo_managed"/>
    <publish render="form" sets="local"/>  -->

    <dbCore queriedTable="main">
      <condDesc original="//siap#protoInput"/>
      <condDesc original="//siap#humanInput"/>
      <condDesc>
        <inputKey original="plate">
            <values fromdb="plate FROM \schema.main ORDER BY plate"/>
        </inputKey>
      </condDesc> 
    </dbCore>

    <outputTable>
      <outputField name="dlurl" type="text" select="accref"
        tablehead="Datalink Access"
        description="URL of a datalink document for the dataset
          (cutouts, different formats, etc)">
        <formatter>
          yield T.a(href=getDatalinkMetaLink(
            rd.getById("dl"), data)
            )["Datalink"]
        </formatter>
        <property name="targetType"
          >application/x-votable+xml;content=datalink</property>
        <property name="targetTitle">Datalink</property>
      </outputField>
      <autoCols>*</autoCols>
    </outputTable>
  </service>

  <service id="dl" allowed="dlget,dlmeta">
    <meta name="description">Datalink for Byurakan survey plates</meta>
    <datalinkCore>
      <descriptorGenerator procDef="//soda#fits_genDesc"
          name="genFITSDesc">
        <bind key="accrefPrefix">'dfbs/data'</bind>
        <bind key="qnd">True</bind>
      </descriptorGenerator>
      <FEED source="//soda#fits_standardDLFuncs"/>
    </datalinkCore>
  </service>

  <regSuite title="dfbs regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

<!--    <regTest title="dfbs SIAP serves some data">
      <url POS="28.394,19.222" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        self.assertHasStrings(
          "%some characteristic string returned by the query%",
          "%another characteristic string returned by the query%")
      </code>
    </regTest> -->

    <regTest title="dfbs datalink meta returns links">
      <url ID="ivo://org.gavo.dc/~?dfbs/data/FBS0900_COR.FITS">dl/dlmeta</url>
      <code>
        bySemantics = dict((row["semantics"], row["access_url"])
          for row in self.getVOTableRows())
        self.assertTrue(
          bySemantics["#preview"].endswith(
            "/getproduct/dfbs/data/FBS0900_COR.FITS?preview=True"))
        self.assertTrue(
          bySemantics["#this"].endswith(
            "/getproduct/dfbs/data/FBS0900_COR.FITS"))
      </code>
    </regTest>
  </regSuite>
</resource>

<!-- vi:et:sta:sw=2
-->
