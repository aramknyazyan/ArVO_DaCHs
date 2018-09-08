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
          <bind key="dateObs">None</bind> <!-- TODO -->
          <bind key="bandpassId">None</bind> <!-- TODO: use emulsion, I'd say
          -->
          <bind key="pixflags">"C"</bind>
          <!-- TODO: add dateObs and emulsion here -->
          <bind key="title">@plate</bind>
        </apply>

<!--        <apply procDef="//siap#getBandFromFilter"/> -->

        <apply procDef="//siap#computePGS"/>

        <map key="plate" source="PLATENUM"/>
<!-- TODO: fix this -->
        <map key="exptime">None</map>
      </rowmaker>
    </make>
  </data>

  <service id="i" allowed="form,siap.xml">
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
  </service>

  <regSuite title="dfbs regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

    <regTest title="dfbs SIAP serves some data">
      <url POS="28.394,19.222" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        self.assertHasStrings(
          "%some characteristic string returned by the query%",
          "%another characteristic string returned by the query%")
      </code>
    </regTest>
  </regSuite>
</resource>
