<resource schema="dfbsplates">
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

    <!-- in the following, just delete any attribute you don't want to
    set.
    
    Get the target class, if any, from 
    http://simbad.u-strasbg.fr/guide/chF.htx -->
    <mixin
      calibLevel="2"
      collectionName="'%a few letters identifying this data%'"
      targetName="%column name of an object designation%"
      expTime="%column name of an exposure time%"
      targetClass="'%simbad taget class%'"
    >//obscore#publishSIAP</mixin>

    %add further columns, in particular for target name, exposure time...%
  </table>

  <coverage>
    <updater sourceTable="main"/>
  </coverage>

  <!-- if you have data that is continually added to, consider using
    updating="True" and an ignorePattern here; see also howDoI.html,
    incremental updating -->
  <data id="import">
    <sources pattern="%resdir-relative pattern, like data/*.fits%"/>

    <!-- the fitsProductGrammar should do it for whenever you have
    halfway usable FITS files.  If they're not halfway usable,
    consider running a processor to fix them first – you'll hand
    them out to users, and when DaCHS can't deal with them, chances
    are their clients can't either -->
    <fitsProductGrammar>
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.data"</bind>
      </rowfilter>
    </fitsProductGrammar>

    <make table="main">
      <rowmaker>
        <!-- put vars here to pre-process FITS keys that you need to
          re-format in non-trivial ways. -->
        <apply procDef="//siap#setMeta">
          <!-- DaCHS can deal with some time formats; otherwise, you
            may want to use parseTimestamp(@DATE_OBS, '%Y %m %d...') -->
          <bind key="dateObs">%something like @DATE_OBS%</bind>

          <!-- bandpassId should be one of the keys from
            dachs adm dumpDF data/filters.txt;
            perhaps use //procs#dictMap for clean data from the header. -->
          <bind key="bandpassId">@FILTER</bind>

          <!-- pixFlags is one of: C atlas image or cutout, F resampled, 
            X computed without interpolation, Z pixel flux calibrated, 
            V unspecified visualisation for presentation only -->
          <bind key="pixFlags">%see comment%</bind>
          
          <!-- titles are what users usually see in a selection, so
            try to combine band, dateObs, object..., like
            "MyData {} {} {}".format(@DATE_OBS, @TARGET, @FILTER) -->
          <bind key="title">%an expression to build a good title%</bind>
        </apply>

        <apply procDef="//siap#getBandFromFilter"/>

        <apply procDef="//siap#computePGS"/>

        <!-- any custom columns need to be mapped here; do *not* use
          idmaps="*" with SIAP -->
      </rowmaker>
    </make>
  </data>

  <!-- if you want to build an attractive form-based service from
    SIAP, you probably want to have a custom form service; for
    just basic functionality, this should do, however. -->
  <service id="i" allowed="form,siap.xml">
    <meta name="shortName">%up to 16 characters%</meta>

    <!-- other sia.types: Cutout, Mosaic, Atlas -->
    <meta name="sia.type">Pointed</meta>
    
    <meta name="testQuery.pos.ra">%ra one finds an image at%</meta>
    <meta name="testQuery.pos.dec">%dec one finds an image at%</meta>
    <meta name="testQuery.size.ra">0.1</meta>
    <meta name="testQuery.size.dec">0.1</meta>

    <!-- this is the VO publication -->
    <publish render="form,scs.xml" sets="ivo_managed"/>
    <!-- this puts the service on the root page -->
    <publish render="form" sets="local"/>
    <!-- all publish elements only become active after you run
      dachs pub q -->

    <dbCore queriedTable="main">
      <condDesc original="//siap#protoInput"/>
      <condDesc original="//siap#humanInput"/>
      <!-- enable further parameters like
        <condDesc buildFrom="dateObs"/>

        or

        <condDesc>
          <inputKey name="object" type="text" 
              tablehead="Target Object" 
              description="Object being observed, Simbad-resolvable form"
              ucd="meta.name" verbLevel="5" required="True">
              <values fromdb="object FROM lensunion.main"/>
          </inputKey>
        </condDesc> -->
    </dbCore>
  </service>

  <regSuite title="dfbs regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

    <regTest title="dfbs SIAP serves some data">
      <url POS="%ra,dec that has a bit of data%" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        <!-- to figure out some good strings to use here, run
          dachs test -D tmp.xml q
          and look at tmp.xml -->
        self.assertHasStrings(
          "%some characteristic string returned by the query%",
          "%another characteristic string returned by the query%")
      </code>
    </regTest>

    <!-- add more tests: image actually delivered, form-based service
      renders custom widgets, etc. -->
  </regSuite>
</resource>
