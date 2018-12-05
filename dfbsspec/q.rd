<resource schema="dfbsspec">
  <meta name="title">Digitized First Byurakan Survey (DFBS) Extracted Spectra</meta>
  <meta name="description" format="rst">
    The First Byurakan Survey (FBS) is the largest and the first systematic
    objective prism survey of the extragalactic sky. It covers 17,000 sq.deg.
    in the Northern sky together with a high galactic latitudes region in the
    Southern sky. The FBS has been carried out by B.E. Markarian, V.A.
    Lipovetski and J.A. Stepanian in 1965-1980 with the Byurakan Observatory
    102/132/213 cm (40"/52"/84") Schmidt telescope using 1.5 deg. prism. Each
    FBS plate contains low-dispersion spectra of some 15,000-20,000 objects;
    the whole survey consists of about 20,000,000 objects. The objects
    selection can be made by their colour, broad emission or absorption lines,
    SED in order to discover, classify and investigate them. The original aim
    was to search for galaxies with UV excess (:bibcode:`1986ApJS...62..751M`,
    Markarian et al. 1989,1997- catalogue No. VII/172 at CDS). Successively,
    the amount of spectral information contained in the plates allowed the
    development of several other projects concerning the spectral
    classification of Seyfert Galaxies (Weedman and Kachikian 1971), the first
    definition of starburst galaxies (Weedman 1977 ), the discovery and
    investigation of blue stellar objects (Abrahamian and Mickaelian, 1996,
    Mickaelian et al 2001, 2002, CDS catalogue No II/223) and a survey for
    late-type stars (Gigoyan et al. 2002). All these results were obtained by
    eye inspection of the plates performed with the aid of a microscope at the
    Byurakan Observatory. The number and classes of new objects discovered FBS
    made clear the need of open access to FBS for the entire astronomical
    community.
  </meta>
  <meta name="creationDate">2017-11-28T10:50:00Z</meta>
  <meta name="subject">objective prism</meta>
  <meta name="subject">spectroscopy</meta>

  <meta name="creator">Markarian, B.E.; N.N.</meta>
  <meta name="instrument">Byurakan 1m Schmidt</meta>
  <meta name="facility">Byurakan Astrophysical Observatory BAO</meta>

  <meta name="source">2007A&amp;A...464.1177M</meta>
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>

  <meta name="coverage">
    <meta name="waveband">Optical</meta>
  </meta>

  <table id="raw_spectra" onDisk="true" adql="hidden">
     <mixin>//products#table</mixin>
     <mixin>//scs#q3cindex</mixin>
    <meta name="description">
      Raw metadata for the spectra, to be combined with image
      metadata like date_obs and friends for a complete spectrum
      descriptions.  This also contains spectral and flux points
      in array-valued columns.
    </meta>

<!--    <primary>spec_id</primary> -->
    <index columns="plate"/>
    <index columns="spec_id"/>
    <index columns="pos" method="GIST"/>

    <column name="spec_id" type="text"
      ucd="meta.id;meta.main"
      tablehead="ID"
      description="Identifier of the spectrum built from the plate identifier,
        a -, and the object position as in objectid."
      verbLevel="25"/>
    <column name="plate" type="text"
      ucd=""
      tablehead="Src. Plate"
      description="Number of the plate this spectrum was extracted
        from.  Technically, this is a foreign key into dfbs.plates."
      verbLevel="1"/>
    <column name="objectid" type="text"
      ucd="meta.id"
      tablehead="Obj."
      description="Synthetic object id assigned by DFBS."
      verbLevel="1"/>
    <column name="ra" type="double precision"
      unit="deg" ucd="pos.eq.ra;meta.main"
      tablehead="RA"
      description="ICRS RA of the source of this spectrum."
      verbLevel="1"/>
    <column name="dec" type="double precision"
      unit="deg" ucd="pos.eq.dec;meta.main"
      tablehead="Dec"
      description="ICRS Dec of the source of this spectrum."
      verbLevel="1"/>
    <column name="pos" type="spoint"
      ucd="pos.eq"
      tablehead="Pos"
      description="The object position as s pgsphere spoint."
      verbLevel="30"/>

    <column name="sp_class" type="text"
      ucd="meta.code.qual"
      tablehead="Sp. Class"
      description="Quality indicator: OK of undisturbed spectra of sufficiently
        bright objects, NL if disturbers are nearby, U for objects
        unclassifiable because of lack of signal."
      verbLevel="25"/>
    <column name="px_length" 
      unit="pixel" ucd=""
      tablehead="#px"
      description="Number of pixels in the extracted spectrum"
      verbLevel="25"/>

    <column name="spectral" type="real[]"
      unit="m" ucd=""
      tablehead="Spectral[]"
      description="Spectral points of the extracted spectrum (wavelengths) as an
        array"
      verbLevel="30"/>
    <column name="flux" type="real[]"
      unit="" ucd=""
      tablehead="Flux[]"
      description="Flux points of the extracted spectrum (arbitrary units)"
      verbLevel="30"/>

    <column name="magb" 
      unit="mag" ucd="phot.mag;em.opt.B"
      tablehead="mag. B"
      description="Source object magnitude in Johnson B"
      verbLevel="15"/>
    <column name="magr" 
      unit="mag" ucd="phot.mag;em.opt.R"
      tablehead="mag. R"
      description="Source object magnitude in Johnson R"
      verbLevel="15"/>
    
    <column name="snr"
      unit="" ucd=""
      tablehead="SNR"
      description="Estimated signal-to-noise ratio for this spectrum."
      verbLevel="25"/>
    <column name="lam_min"
      unit="m" ucd=""
      tablehead="λ_min"
      description="Minimal wavelength in this spectrum."
      verbLevel="15"/>
    <column name="lam_max"
      unit="m" ucd=""
      tablehead="λ_max"
      description="Maximal wavelength in this spectrum."
      verbLevel="15"/>
  </table>

  <data id="import">
    <recreateAfter>make_ssa_view</recreateAfter>
    <recreateAfter>make_tap_view</recreateAfter>
    <property key="previewDir">previews</property>
    <sources pattern="data/*.zip"/>
    <embeddedGrammar notify="True">
      <iterator>
        <setup>
          <code><![CDATA[
            import re
            import numpy
            import zipfile
            
            # see README for plate id disambiguation
            DECRANGES_FOR_PLATEID_DEDUP = {
              "fbs0326": (25, 35),
              "fbs0449": (25, 35),
              "fbs0996": (42, 54)}

            def parse_a_spectrum(src_f):
              """returns a rawdict from an open file.
              
              This can raise all kinds of exceptions depending on
              the way in which the source is broken.
              """
              lam_max, lam_min = 0, 1e30
              spectral, flux = [], []

              res = {}
              for ln in src_f:
                if ln.startswith("# "):
                  if not ":" in ln:
                    continue
                  key, value = ln[1:].strip().split(":", 1)
                  res[re.sub("[^A-Za-z]+", "", key)] = value.strip()
                elif ln.startswith("##"):
                  pass
                else:
                  px, flx, lam = ln.split()
                  lam = float(lam)*1e-9
                  # discard everything longward of 690 nm, as it's certainly
                  # not physical.
                  if lam>7e-7:
                    continue
                  lam_max = max(lam_max, lam)
                  lam_min = min(lam_min, lam)
                  flux.append(float(flx))
                  spectral.append(lam)

              if res["plate"] in DECRANGES_FOR_PLATEID_DEDUP:
                dec = dmsToDeg(decJ, ":")
                lowerDec, upperDec = DECRANGES_FOR_PLATEID_DEDUP[res["plate"]]
                if lowerDec<dec<upperDec:
                  res["plate"] = res["plate"]+"a"

              res["lam_max"] = lam_max
              res["lam_min"] = lam_min
              res["flux"] = numpy.array(flux)
              res["spectral"] = numpy.array(spectral)
              res["spec_id"] = res["plate"] + "-" + res["objectid"][5:]

              return res
          ]]></code>
        </setup>
        <code>
          zipSource = zipfile.ZipFile(self.sourceToken, mode="r")
          for memberName in zipSource.namelist():
            if not memberName.endswith(".spec"):
              continue

            f = zipSource.open(memberName, "r")
            
            try:
              yield parse_a_spectrum(f)
            except Exception as exc:
              base.ui.notifyError("Botched spectrum: %s %s %s"%(
                self.sourceToken, memberName, exc))
              continue

        </code>
      </iterator>

      <rowfilter procDef="//products#define">
        <bind name="table">"\schema.spectra"</bind>
        <bind key="accref">"\rdId/"+@spec_id</bind>
        <bind name="path">makeAbsoluteURL(
          "\rdId/sdl/dlget?ID="+urllib.quote("\rdId/"+@spec_id))</bind>
        <bind name="mime">"application/x-votable+xml"</bind>
        <bind name="preview_mime">"image/png"</bind>
        <bind name="preview">\standardPreviewPath</bind>
        <bind name="fsize">20000</bind>
      </rowfilter>
    </embeddedGrammar>

    <make table="raw_spectra">
      <rowmaker idmaps="*">
        <simplemaps>
          sp_class: spectrumclass,
          magb: magB,
          magr: magR
        </simplemaps>

        <var key="ra">hmsToDeg(@raJ, ":")</var>
        <var key="dec">dmsToDeg(@decJ, ":")</var>
        <map key="px_length">float(@spectrumlength.split(" ")[0])</map>
        <map key="pos">pgsphere.SPoint.fromDegrees(@ra, @dec)</map>

        <apply name="compute_snr">
          <code>
            mag = float(@magB)
            if mag>16:
              @snr = 3
            elif mag>14:
              @snr = 5
            else:
              @snr = 100
          </code>
        </apply>
      </rowmaker>
    </make>
  </data>

  <table id="ssa" onDisk="true" namePath="raw_spectra">
    <meta name="description">A view providing standard SSA metadata for
      DBFS metadata in \schema.spectra</meta>
    <mixin
      fluxUnit=" "
      fluxUCD="phot.flux.density"
      spectralUnit="m">//ssap#mixc</mixin>
    <mixin>//ssap#simpleCoverage</mixin>
    <mixin>//obscore#publishSSAPMIXC</mixin>
    
    <column original="magb"/>
    <column original="magr"/>
    <column original="plate"/>

    <viewStatement>
    CREATE VIEW \curtable AS (
      SELECT \colNames FROM (
        SELECT
          accref, owner, embargo, mime, accsize,
          objectid || ' spectrum from ' || plate AS ssa_dstitle,
          NULL::TEXT AS ssa_creatorDID,
          'ivo://\getConfig{ivoa}{authority}/~?\rdId/' || spec_id AS ssa_pubDID,
          NULL::TEXT AS ssa_cdate,
          '2018-09-01'::TIMESTAMP AS ssa_pdate,
          emulsion AS ssa_bandpass,
          '1.0'::TEXT AS ssa_cversion,
          NULL::TEXT AS ssa_targname,
          NULL::TEXT AS ssa_targclass,
          NULL::REAL AS ssa_redshift,
          NULL::spoint AS ssa_targetpos,
          snr AS ssa_snr,
          pos AS ssa_location,
          2/3600.::REAL AS ssa_aperture,
          epoch AS ssa_dateObs, 
          exptime AS ssa_timeExt,
          (lam_min+lam_max)/2. AS ssa_specmid,
          lam_max-lam_min AS ssa_specext,
          lam_min AS ssa_specstart,
          lam_max AS ssa_specend,
          px_length::INTEGER AS ssa_length,
          'spectrum'::TEXT AS ssa_dstype,
          'BAO'::TEXT AS ssa_publisher,
          'Markarian et al'::TEXT AS ssa_creator,
          'DFBS spectra'::TEXT AS ssa_collection,
          'Byurakan 1m Schmidt'::TEXT AS ssa_instrument,
          'survey'::TEXT AS ssa_datasource,
          'archival'::TEXT AS ssa_creationtype,
          '2007A&amp;A...464.1177M'::TEXT AS ssa_reference,
          NULL::REAL AS ssa_fluxStatError,
          NULL::REAL AS ssa_fluxSysError,
          'UNCALIBRATED'::TEXT AS ssa_fluxcalib,
          50e-10::REAL AS ssa_binSize,
          NULL::REAL AS ssa_spectStatError,
          NULL::REAL AS ssa_spectSysError,
          'ABSOLUTE'::TEXT AS ssa_speccalib,
          50e-10::REAL AS ssa_specres,
          NULL::spoly AS ssa_region,
          magb, magr, plate
        FROM \schema.raw_spectra
        LEFT OUTER JOIN \schema.platemeta
        ON (plateid=plate)
      ) AS q
    )
    </viewStatement>
  </table>

  <coverage>
    <updater sourceTable="ssa"/>
    <spatial>6/666-667,689</spatial>
    <temporal/>
    <spectral/>
  </coverage>

  <data id="make_ssa_view" auto="False">
    <property key="previewDir">previews</property>
    <make table="ssa"/>
  </data>

  <table id="platemeta" onDisk="True" primary="plateid"
      adql="hidden">
    <meta name="description">Metadata for the plates making up the
    Byurakan spectral surveys, obtained from the WFPDB.</meta>

    <column name="plateid" type="text"
      ucd="meta.id;meta.main"
      tablehead="Plate"
      description="Identifier of the plate; this is 'fbs' plus the plate
        number."
      verbLevel="1"/>
    <column name="epoch" type="double precision"
      unit="d" ucd="time.epoch"
      tablehead="Date Obs."
      description="Date of observation from WFPDB (this probably does not
        include the time)."
      verbLevel="1"/>
    <column name="exptime"
      unit="s" ucd="time.duration;obs.exposure"
      tablehead="Exp. Time"
      description="Exposure time from WFPDB."
      verbLevel="1"/>
    <column name="emulsion" type="text"
      ucd="instr.plate.emulsion"
      tablehead="Emulsion"
      description="Emulsion used in this plate from WFPDB."
      verbLevel="1"/>
  </table>

  <data id="import_platemeta">
    <!-- we pull data from the GAVO DC's wfpdb mirror.  It might pay
      to re-run this now and then as WFPDB data gets updated.. -->
    <recreateAfter>make_ssa_view</recreateAfter>
    <recreateAfter>make_tap_view</recreateAfter>
    <sources item="http://dc.g-vo.org/tap/sync"/>
    <embeddedGrammar>
      <iterator>
        <code>
          from urllib import urlencode
          from gavo import votable
          from gavo.stc import jYearToDateTime, dateTimeToMJD

          f = utils.urlopenRemote(self.sourceToken, data=urlencode({
            "LANG": "ADQL",
            "QUERY": "select object as plateid, epoch, exptime, emulsion"
              " from wfpdb.main"
              " where object is not null and object!=''"
              "   and instr_id='BYU102A'"
              "   and method='objective prism'"}))

          data, metadata = votable.load(f)
          for row in metadata.iterDicts(data):

            # HACK: duplicates in WFPDB.  See README
            if row["plateid"]=="NPS":
              continue
            if row["plateid"]=="FBS 0966" and int(row["epoch"])==1974:
              row["plateid"] = "FBS 0966a"
            if row["plateid"]=="FBS 0326" and row["epoch"]>1971.05:
              row["plateid"] = "FBS 0326a"
            if row["plateid"]=="FBS 0449" and row["epoch"]>1971.38:
              row["plateid"] = "FBS 0449a"
              

            row["epoch"] = dateTimeToMJD(jYearToDateTime(row["epoch"]))
            row["plateid"] = row["plateid"].replace("FBS ", "fbs")
            yield row
        </code>
      </iterator>
    </embeddedGrammar>

    <make table="platemeta"/>
  </data>


  <table id="spectra" onDisk="True" adql="True">
    <meta name="description">This table contains basic metadata as well
      as the spectra from the Digital First Byurakan Survey (DFBS).
    </meta>
    <LOOP listItems="accref plate objectid ra dec pos sp_class px_length
        spectral flux magb magr snr lam_min lam_max">
      <events>
        <column original="raw_spectra.\item"/>
      </events>
    </LOOP>
    <LOOP listItems="epoch exptime emulsion">
      <events>
        <column original="platemeta.\item"/>
      </events>
    </LOOP>
    <viewStatement>
      CREATE VIEW \curtable AS (
        SELECT \colNames FROM (
          SELECT * FROM 
            \schema.raw_spectra
            JOIN \schema.platemeta
            ON (plate=plateid)) AS t)
    </viewStatement>
  </table>

  <data id="make_tap_view">
    <make table="spectra"/>
  </data>


  <table id="spectrum">
    <mixin ssaTable="ssa"
      fluxDescription="Relative Flux"
      spectralDescription="Wavelength"
      >//ssap#sdm-instance</mixin>
  </table>

  <data id="build_sdm_data" auto="False">
    <embeddedGrammar>
      <iterator>
        <code>
          with base.getTableConn() as conn:
            res = list(conn.query(
              "select spectral, flux from dfbsspec.spectra"
              "  where accref=%(accref)s",
              {"accref": self.sourceToken["accref"]}))[0]

          for lam, flx in zip(*res):
            yield {"spectral": lam, "flux": flx}
        </code>
      </iterator>
    </embeddedGrammar>
    <make table="spectrum">
      <parmaker>
        <apply procDef="//ssap#feedSSAToSDM"/>
      </parmaker>
    </make>
  </data>

  <service id="sdl" allowed="dlget,dlmeta,static">
    <meta name="title">DFBS Datalink Service</meta>

    <property name="staticData">data</property>

    <datalinkCore>
      <descriptorGenerator procDef="//soda#sdm_genDesc">
        <bind name="ssaTD">"\rdId#ssa"</bind>
      </descriptorGenerator>
      <dataFunction procDef="//soda#sdm_genData">
        <bind name="builder">"\rdId#build_sdm_data"</bind>
      </dataFunction>
      <metaMaker>
        <code>
          yield descriptor.makeLinkFromFile(
            os.path.join(base.getConfig("inputsDir"), descriptor.accref),
            description="Spectrum in original text format as provided by the"
              " extractor.",
            semantics="#progenitor")
        </code>
      </metaMaker>
      <FEED source="//soda#sdm_plainfluxcalib"/>
      <FEED source="//soda#sdm_format"/>
    </datalinkCore>
  </service>

  <service id="web">
    <meta name="title">Digitized First Byurakan Survey Browser Interface</meta>
    <dbCore queriedTable="ssa">
      <condDesc buildFrom="ssa_location"/>
      <condDesc buildFrom="magb"/>
    </dbCore>
<!--    <outputTable
autoCols="accref,accsize,ssa_location,ssa_dstitle,magr,magb,dlurl,ssa_snr"/>-->
  </service>

  <service id="getssa" allowed="ssap.xml,form">
    <meta name="shortName">DFBS SSAP</meta>
    <meta name="ssap.dataSource">pointed</meta>
    <meta name="ssap.testQuery">MAXREC=1</meta>
    <meta name="ssap.creationType">archival</meta>
    <meta name="ssap.complianceLevel">query</meta>

    <ssapCore queriedTable="ssa">
      <FEED source="//ssap#hcd_condDescs"/>
    </ssapCore>
  </service>

  <regSuite title="DFBS regression">
    <regTest title="Spectra metadata plausible via SSA">
      <url REQUEST="queryData" POS="29.0426958,-54.39563"
        SIZE="0.001">getssa/ssap.xml</url>
      <code>
        row = self.getFirstVOTableRow()
        self.assertEqual(row['ssa_location'].asSODA(),	
          '29.0426958306 -54.3956250028')
        self.assertEqual(row["ssa_dstitle"], 
          'DFBSJ015610.24+202225.0 spectrum from fbs1163')
        self.assertEqual(row["ssa_bandpass"], "IIF")
        self.assertEqual(row["ssa_length"], 109)
        self.assertAlmostEqual(row["ssa_specstart"], 3.206e-07)
        self.assertAlmostEqual(row["ssa_dateObs"], 42332.000, places=3)
      </code>
    </regTest>

    <regTest title="DFBS previews present">
      <url>/getproduct/dfbsspec/q/fbs1163-015613.29+201136.2?preview=True</url>
      <code>
        self.assertHasStrings("PNG", "IDATx")
      </code>
    </regTest>

    <regTest title="Datalink dataset generation works">
      <url ID="ivo://org.gavo.dc/~?dfbsspec/q/fbs1163-015613.29+201136.2"
        >sdl/dlget</url>
      <code>
        self.assertHasStrings('utype="spec:Spectrum"', 'name="citation"',
          'value="UNCALIBRATED"')
        rows = self.getVOTableRows()
        self.assertAlmostEqual(rows[-1]["spectral"], 3.214e-07)
        self.assertAlmostEqual(rows[-1]["flux"], 0.03)
      </code>
    </regTest>

    <regTest title="spectra TAP table present">
      <url parSet="TAP" QUERY="SELECT * FROM dfbsspec.spectra
        WHERE objectid='DFBSJ015610.24+202225.0'"
        >/tap/sync</url>
      <code>
        rows = self.getVOTableRows()
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertAlmostEqual(row["lam_min"],  3.2060000e-07)
        self.assertAlmostEqual(row["dec"],  305.604375)
        self.assertEqual(row["emulsion"],  "IIF")
        self.assertAlmostEqual(row["flux"][2], 0.09000000)
        self.assertAlmostEqual(row["spectral"][1], 9.771999884833349e-07)
      </code>
    </regTest>
  </regSuite>

</resource>

<!-- vi:et:sta:sw=2
-->
