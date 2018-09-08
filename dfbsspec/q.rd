<!--
* remaining metadata from spectra
* metadata from source images (dateObs!)
* description, additional service parameters
* coverage profile, creator
-->
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

  <table id="spectra" onDisk="true" adql="hidden" mixin="//products#table">
    <meta name="description">
      Raw metadata for the spectra, to be combined with image
      metadata like date_obs and friends for a complete spectrum
      descriptions.  This also contains spectral and flux points
      in array-valued columns.
    </meta>

    <primary>spec_id</primary>
    <index columns="plate"/>
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
      description="TODO"
      verbLevel="25"/>
    <column name="px_length" 
      unit="px" ucd=""
      tablehead="#px"
      description="Number of pixels in the extracted spectrum"
      verbLevel="25"/>

    <column name="spectral" type="real[]"
      unit="nm" ucd=""
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
    <property key="previewDir">previews</property>
    <sources pattern="data/*.zip"/>
    <embeddedGrammar>
      <iterator>
        <setup>
          <code>
            import re
            import numpy
            import zipfile
          </code>
        </setup>
        <code>
          zipSource = zipfile.ZipFile(self.sourceToken, mode="r")
          for memberName in zipSource.namelist():
            if not memberName.endswith(".spec"):
              continue


            f = zipSource.open(memberName, "r")
            lam_max, lam_min = 0, 1e30
            spectral, flux = [], []

            res = {}
            for ln in f:
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
                lam_max = max(lam_max, lam)
                lam_min = min(lam_min, lam)
                flux.append(float(flx))
                spectral.append(lam)

            res["lam_max"] = lam_max
            res["lam_min"] = lam_min
            res["flux"] = numpy.array(flux)
            res["spectral"] = numpy.array(spectral)
            res["spec_id"] = res["plate"] + "-" + res["objectid"][5:]
            yield res
        </code>
      </iterator>

      <rowfilter procDef="//products#define">
        <bind name="table">"\schema.data"</bind>
        <bind key="accref">"\rdId/"+@spec_id</bind>
        <bind name="path">makeAbsoluteURL(
          "\rdId/sdl/dlget?ID="+urllib.quote(@spec_id))</bind>
        <bind name="mime">"application/x-votable+xml"</bind>
        <bind name="preview_mime">"image/png"</bind>
        <bind name="preview">\standardPreviewPath</bind>
        <bind name="fsize">20000</bind>
      </rowfilter>
    </embeddedGrammar>

    <make table="spectra">
      <rowmaker idmaps="*">
        <simplemaps>
          sp_class: spectrumclass,
          magb: magB,
          magr: magR
        </simplemaps>

        <var key="ra">hmsToDeg(@raJ, ":")</var>
        <var key="dec">hmsToDeg(@decJ, ":")</var>
        <map key="px_length">float(@spectrumlength.split(" ")[0])</map>
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

  <table id="data" onDisk="true" namePath="spectra">
    <meta name="description">A view providing standard SSA metadata for
      DBFS metadata in \schema.spectra</meta>
    <mixin
      fluxUnit=" "
      fluxUCD="phot.flux.density"
      spectralUnit="nm">//ssap#mixc</mixin>
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
          'DFBS spectrum ' || objectid AS ssa_dstitle,
          NULL::TEXT AS ssa_creatorDID,
          'ivo://\getConfig{ivoa}{authority}/~?' || spec_id AS ssa_pubDID,
          NULL::TEXT AS ssa_cdate,
          '2018-09-01'::DATE AS ssa_pdate,
          'Optical'::TEXT AS ssa_bandpass,
          '1.0'::TEXT AS ssa_cversion,
          NULL::TEXT AS ssa_targname,
          NULL::TEXT AS ssa_targclass,
          NULL::REAL AS ssa_redshift,
          NULL::spoint AS ssa_targetpos,
          snr AS ssa_snr,
          pos AS ssa_location,
          2/3600.::REAL AS ssa_aperture,
          NULL::DOUBLE PRECISION AS ssa_dateObs, -- FIXME
          NULL::REAL AS ssa_timeExt, -- FIXME
          (lam_min+lam_max)/2. AS ssa_specmid,
          lam_max-lam_min AS ssa_specext,
          lam_min AS ssa_specstart,
          lam_max AS ssa_specend,
          px_length AS ssa_length,
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
        FROM \schema.spectra
      ) AS q
    )
    </viewStatement>
  </table>

  <coverage>
    <updater sourceTable="data"/>
    <spatial>6/666-667,689</spatial>
    <temporal/>
    <spectral/>
  </coverage>

  <data id="make_view" auto="False">
    <property key="previewDir">previews</property>
    <make table="data"/>
  </data>

  <table id="spectrum">
    <mixin ssaTable="data"
      fluxDescription="Relative Flux"
      spectralDescription="Wavelength"
      >//ssap#sdm-instance</mixin>
  </table>

  <data id="build_sdm_data" auto="False">
    <embeddedGrammar>
      <iterator>
        <code>
          sourcePath = os.path.join(base.getConfig("inputsDir"),
              self.sourceToken["accref"])
          with open(sourcePath) as f:
            for ln in f:
              if ln.startswith("#"):
                continue
              elif not ln.strip():
                continue
              else:
                px, flux, lam = ln.split()
                yield {
                  "spectral": float(lam),
                  "flux": float(flux)
                }
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
        <bind name="ssaTD">"\rdId#data"</bind>
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
    <dbCore queriedTable="data">
      <condDesc buildFrom="ssa_location"/>
      <condDesc buildFrom="magb"/>
    </dbCore>
<!--    <outputTable
autoCols="accref,accsize,ssa_location,ssa_dstitle,magr,magb,dlurl,ssa_snr"/>-->
  </service>

  <service id="ssa" allowed="ssap.xml,form">
    <meta name="shortName">DFBS SSAP</meta>
    <meta name="ssap.dataSource">pointed</meta>
    <meta name="ssap.testQuery">MAXREC=1</meta>
    <meta name="ssap.creationType">archival</meta>
    <meta name="ssap.complianceLevel">query</meta>

    <ssapCore queriedTable="data">
      <FEED source="//ssap#hcd_condDescs"/>
    </ssapCore>
  </service>

  <regSuite title="DFBS regression">
    <regTest title="Spectra metadata plausible via SSA">
      <url REQUEST="queryData" POS="322.932108332,-12.7728472233"  
        SIZE="0.001">ssa/ssap.xml</url>
      <code>
        row = self.getFirstVOTableRow()
        self.assertAlmostEqual(row['ssa_location'].asSODA(),	
          "322.932108332 -12.7728472233")
        self.assertTrue(row["dlurl"].endswith("/dfbs/q/sdl/dlmeta?"
          "ID=ivo%3A//org.gavo.dc/%7E%3Fdfbs/data/tmpdata/"
          "fbs1053-DFBSJ213143.70-124622.2.spec"))
        self.assertEqual(row["ssa_dstitle"], 
          'DFBS spectrum DFBSJ213143.70-124622.2')
      </code>
    </regTest>

    <regTest title="DFBS previews present">
      <url>/getproduct/dfbs/data/tmpdata/fbs1053-DFBSJ213148.47-125004.7.spec?preview=True</url>
      <code>
        self.assertHasStrings("PNG", "IDATx")
      </code>
    </regTest>

    <regTest title="DFBS datalink meta has progenitor link">
      <url ID="ivo://org.gavo.dc/~?dfbs/data/tmpdata/fbs1053-DFBSJ213143.70-124622.2.spec">sdl/dlmeta</url>
      <code>
        rows = self.getVOTableRows()
        for row in rows:
          if row["semantics"]=="#progenitor":
            self.assertTrue(row["access_url"].endswith(
              "/dfbs/q/sdl/static/tmpdata/fbs1053-DFBSJ213143.70-124622.2.spec"),
              "Progenitor link in datalink access_url column not in expected"
              " form")
      </code>
    </regTest>

    <regTest title="Datalink dataset generation works">
      <url ID="ivo://org.gavo.dc/~?dfbs/data/tmpdata/fbs1053-DFBSJ213143.70-124622.2.spec">sdl/dlget</url>
      <code>
        self.assertHasStrings('utype="spec:Spectrum"', 'name="citation"',
          'value="UNCALIBRATED"')
        self.assertEqual(self.getFirstVOTableRow()["spectral"], 1038.0)
      </code>
    </regTest>
  </regSuite>
</resource>

<!-- vi:et:sta:sw=2
-->
