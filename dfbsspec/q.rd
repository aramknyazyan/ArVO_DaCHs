<resource schema="dfbsspec">
  <macDef name="spectralBins">6.9E-7, 6.789E-7, 6.682E-7, 6.58E-7, 6.482E-7, 6.388E-7, 6.298E-7, 6.212E-7, 6.129E-7, 6.049E-7, 5.972E-7, 5.897E-7, 5.826E-7, 5.757E-7, 5.69E-7, 5.626E-7, 5.564E-7, 5.503E-7, 5.445E-7, 5.389E-7, 5.334E-7, 5.281E-7, 5.23E-7, 5.18E-7, 5.132E-7, 5.085E-7, 5.039E-7, 4.995E-7, 4.952E-7, 4.91E-7, 4.869E-7, 4.829E-7, 4.791E-7, 4.753E-7, 4.717E-7, 4.681E-7, 4.646E-7, 4.612E-7, 4.579E-7, 4.547E-7, 4.515E-7, 4.484E-7, 4.454E-7, 4.425E-7, 4.396E-7, 4.368E-7, 4.34E-7, 4.314E-7, 4.287E-7, 4.262E-7, 4.236E-7, 4.212E-7, 4.188E-7, 4.164E-7, 4.141E-7, 4.118E-7, 4.096E-7, 4.074E-7, 4.053E-7, 4.032E-7, 4.011E-7, 3.991E-7, 3.972E-7, 3.952E-7, 3.933E-7, 3.915E-7, 3.896E-7, 3.878E-7, 3.86E-7, 3.843E-7, 3.826E-7, 3.809E-7, 3.793E-7, 3.777E-7, 3.761E-7, 3.745E-7, 3.73E-7, 3.714E-7, 3.7E-7, 3.685E-7, 3.671E-7, 3.656E-7, 3.642E-7, 3.629E-7, 3.615E-7, 3.602E-7, 3.589E-7, 3.576E-7, 3.563E-7, 3.551E-7, 3.538E-7, 3.526E-7, 3.514E-7, 3.502E-7, 3.491E-7, 3.479E-7, 3.468E-7, 3.457E-7, 3.446E-7, 3.435E-7, 3.424E-7, 3.414E-7, 3.403E-7, 3.393E-7, 3.383E-7, 3.373E-7, 3.363E-7, 3.354E-7, 3.344E-7, 3.335E-7, 3.325E-7, 3.316E-7, 3.307E-7, 3.298E-7, 3.289E-7, 3.28E-7, 3.272E-7, 3.263E-7, 3.255E-7, 3.247E-7, 3.238E-7, 3.23E-7, 3.222E-7, 3.214E-7, 3.206E-7, 3.199E-7, 3.191E-7, 3.184E-7, 3.176E-7, 3.169E-7, 3.161E-7, 3.154E-7, 3.147E-7, 3.14E-7, 3.133E-7, 3.126E-7</macDef>

  <meta name="title">Digitized First Byurakan Survey (DFBS) Extracted Spectra</meta>
  <meta name="description" format="rst">
    The First Byurakan Survey (FBS) is the largest and the first systematic
    objective prism survey of the extragalactic sky. It covers 17,000 sq.deg.
    in the Northern sky together with a high galactic latitudes region in the
    Southern sky. The FBS has been carried out by B.E. Markarian, V.A.
    Lipovetski and J.A. Stepanian in 1965-1980 with the Byurakan Observatory
    102/132/213 cm (40"/52"/84") Schmidt telescope using 1.5 deg. prism. Each
    FBS plate contains low-dispersion spectra of some 15,000-20,000 objects;
    the whole survey consists of about 20,000,000 objects.
    
  </meta>

  <meta name="_longdoc" format="rst"><![CDATA[
    Usage Hints
    ===========

    Note that the spectra are not flux calibrated.  Indeed, they
    were scanned off of different emulsions, and only spectra from
    compatible emulsions should be compared.  The following emulsions
    occur in the database:

    =========  ============
      n         emulsion  
    =========  ============
      334409    103aF      
      18695     103aO      
      3622      IF         
      13555     IIAD       
      2409058   IIAF       
      16545     IIAF bkd   
      3254370   IIF        
      313287    IIF bkd    
      7871      IIIAJ bkd  
      6645      IIIF       
      18967     IIIaF      
      8122      IIaD       
      3565737   IIaF       
      6735      IIaO       
      16755     OAF        
      8794      ORWO CP-3  
      8097      ZP-3       
      23702     Zu-2       
    =========  ============

    Upper- and lowercase versions of the emulsions are actually different
    (e.g., IIAD was produced in England, IIaD in the US).  Their properties
    are different enough to make mixing spectra for the different emulsions
    unwise.

    Also note the ``sp_class`` column.  Unless you take great precaution,
    you probably should only use spectra with ``sp_class='OK'``.

    Spectra can be retrieved in VOTable form (via SSA or the accref field
    from the TAP table), but it will usually be faster to directly pull them
    from the spectral and flux arrays.

    Actually, array indices in the flux arrays correspond to fixed wavelengths.
    In other words, the ``spectral`` column is constant in the database.

    The ``flux`` arrays are actually of different length.  The always start
    at index 1, corresponding to 690 nm.  The blue end depends on how far
    some signal was suspected.
    

    Use Cases
    =========

    Locate Spectra by Features
    --------------------------

    While ADQL support for array operations is rather weak, you can subscript
    arrays.  Because of the fixed bins, you can therefore select by flux
    ratios (never use absolute numbers here; they are meaningless).  For
    instance, to select objects with a high (apparent) Halpha emission 
    (656 nm, corresponding to array index 3), you might so something like::

      select * from dfbsspec.spectra
      where 
        flux[3]/(flux[40]+flux[41]+flux[42])>30
        and sp_class='OK'

    Since the table needs to be sequentially scanned for this, it will
    take a minute or so.  Combine with an object selection (see below)
    or other criteria if possible.

    Get Average Spectra
    -------------------

    You cannot currently use the ADQL aggregate function AVG with arrays
    (which should be fixed at some time in the future).  Meanwhile, you can
    work around this with a clumsy construction like this (this query will
    give you average spectra by magnitude bin; don't run it just for fun,
    it'll take a while)::

      select round(magb) as bin, avg(flux[1]) as col1, avg(flux[2]) as col2,
        avg(flux[3]) as col3, avg(flux[4]) as col4, avg(flux[5]) as col5,
        avg(flux[6]) as col6, avg(flux[7]) as col7, avg(flux[8]) as col8,
        avg(flux[9]) as col9, avg(flux[10]) as col10, avg(flux[11]) as col11,
        avg(flux[12]) as col12, avg(flux[13]) as col13, avg(flux[14]) as col14,
        avg(flux[15]) as col15, avg(flux[16]) as col16, avg(flux[17]) as col17,
        avg(flux[18]) as col18, avg(flux[19]) as col19, avg(flux[20]) as col20,
        avg(flux[21]) as col21, avg(flux[22]) as col22, avg(flux[23]) as col23,
        avg(flux[24]) as col24, avg(flux[25]) as col25, avg(flux[26]) as col26,
        avg(flux[27]) as col27, avg(flux[28]) as col28, avg(flux[29]) as col29,
        avg(flux[30]) as col30, avg(flux[31]) as col31, avg(flux[32]) as col32,
        avg(flux[33]) as col33, avg(flux[34]) as col34, avg(flux[35]) as col35,
        avg(flux[36]) as col36, avg(flux[37]) as col37, avg(flux[38]) as col38,
        avg(flux[39]) as col39, avg(flux[40]) as col40, avg(flux[41]) as col41,
        avg(flux[42]) as col42, avg(flux[43]) as col43, avg(flux[44]) as col44,
        avg(flux[45]) as col45, avg(flux[46]) as col46, avg(flux[47]) as col47,
        avg(flux[48]) as col48, avg(flux[49]) as col49, avg(flux[50]) as col50,
        avg(flux[51]) as col51, avg(flux[52]) as col52, avg(flux[53]) as col53,
        avg(flux[54]) as col54, avg(flux[55]) as col55, avg(flux[56]) as col56,
        avg(flux[57]) as col57, avg(flux[58]) as col58, avg(flux[59]) as col59
      from dfbsspec.spectra
      where sp_class='OK'
      group by bin
    
    To map ``col<n>`` to wavelenghts, see the contents of (any) ``spectral``
    column.

    Build Templates
    ---------------

    To compute an average spectrum for a class of objects, we suggest to
    pull positions of such objects from SIMBAD and then fetch the associate
    spectra from this database.  Since the response function of the 
    photographic plates had a strong magnitude dependence, restrict the
    objects to a small magnitude range, for instance::

        select 
            otype, ra, dec, flux
        from basic 
        join flux
        on (oid=oidref)
        where 
            otype='HS*'
            and dec>-15
            and filter='G'
            and flux between 12.5 and 13.5

    (to be executed on SIMBAD's TAP service, see also `SIMBAD object types`_).

    .. _SIMBAD object types: http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes

    With the resulting table, to do this service and execute a query like::

      SELECT
      specid, spectral, flux
      FROM dfbsspec.spectra AS db
      JOIN TAP_UPLOAD.t1 AS tc
      ON DISTANCE(tc.ra, tc.dec, db.ra, db.dec)<5./3600.
      WHERE sp_class='OK'

    (adjust t1 according to your client's rules; in TOPCAT, that's t plus 
    the table number from the control window).

    History of this Data Collection
    ===============================

    The original aim of the First Byurakan Survey
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
  ]]></meta>

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

    <publish sets="ivo_managed,local"/>

    <primary>specid</primary>
    <index columns="plate"/>
    <index columns="accref"/>
    <index columns="specid"/>
    <index columns="pos" method="GIST"/>

    <column name="specid" type="text"
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

    <column name="flux" type="real[]"
      unit="" ucd="phot.flux.density;em.wl"
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
      ucd="stat.snr"
      tablehead="SNR"
      description="Estimated signal-to-noise ratio for this spectrum."
      verbLevel="25"/>
    <column name="lam_min"
      unit="m" ucd="stat.min;em.wl"
      tablehead="λ_min"
      description="Minimal wavelength in this spectrum (the longest 
        wavelength is always 690 nm)."
      verbLevel="15"/>

    <column name="sky"
      ucd="instr.skyLevel"
      tablehead="Sky"
      description="Sky background estimation from the scan (uncalibrated)."
      verbLevel="25"/>
    <column name="px_x"
      unit="pixel" ucd="pos.cartesian.x;instr"
      tablehead="X"
      description="Location of the spectrum on the plate scan, x coordinate."
      verbLevel="25"/>
    <column name="px_y"
      unit="pixel" ucd="pos.cartesian.y;instr"
      tablehead="Y"
      description="Location of the spectrum on the plate scan, y coordinate."
      verbLevel="25"/>
    <column name="pos_ang"
      unit="deg" ucd="pos.posAng"
      tablehead="P.A."
      description="Position angle of the spectrum on the plate, north over
        east."
      verbLevel="25"/>
    <column name="px_length"
      tablehead="#"
      description="Number of points in this spectrum"
      verbLevel="25"/>

  </table>

  <data id="import">
    <recreateAfter>make_ssa_view</recreateAfter>
    <recreateAfter>make_tap_view</recreateAfter>
    <sources pattern="data/*.sql.gz"/>
    <!-- this parses from the SQL dump we got from Italy.  We
    	trust all the fbs_* tables have the same structure. -->
    <embeddedGrammar notify="True">
      <iterator>
        <setup>
          <code><![CDATA[
            import gzip
            import re
            import numpy
            
            # see README for plate id disambiguation
            DECRANGES_FOR_PLATEID_DEDUP = {
              "fbs0326": (25, 35),
              "fbs0449": (25, 35),
              "fbs0996": (42, 54)}

            def parseSpectraFromDump(inputLine):
              """this assumes the schema

              `id` int(11) NOT NULL AUTO_INCREMENT,
              `nome` varchar(55) DEFAULT NULL,
              `ra1` varchar(20) DEFAULT NULL,
              `dec1` varchar(20) DEFAULT NULL,
              `ra2` double DEFAULT '0',
              `dec2` double DEFAULT '0',
              `magB` varchar(20) DEFAULT NULL,
              `magR` varchar(20) DEFAULT NULL,
              `Lun` varchar(20) DEFAULT NULL,
              `redBord` varchar(20) DEFAULT NULL,
              `sn` varchar(20) DEFAULT NULL,
              `x` int(11) DEFAULT NULL,
              `y` int(11) DEFAULT NULL,
              `angolo` varchar(20) DEFAULT NULL,
              `ell` varchar(20) DEFAULT NULL,
              `sky` varchar(20) DEFAULT NULL,
              `profilo` text,
              `classe` varchar(20) DEFAULT NULL,

              throughout.  We also hope there are no literals with commas
              or parentheses in.  If there are, this stuff should exception
              out.
              """
              # we pull the plate name from the table name by
              # cutting off everything after an underscore from the
              # table name.  Let's see if we get away with this.
              plate = re.search("`([^`]*)`", inputLine
                ).group(1).split("_")[0]

              # pull out the first declination so we know where
              # we're looking; this is so we can fix bad plate
              # ids (see README)
              dec = float(
                re.search("\([^,]*,[^,]*,[^,]*,[^,]*,[^,]*,([^,]*)",
                  inputLine).group(1))
              if plate in DECRANGES_FOR_PLATEID_DEDUP:
                lowerDec, upperDec = DECRANGES_FOR_PLATEID_DEDUP[plate]
                if lowerDec<dec<upperDec:
                  plate = plate+"a"

              # now strip off everything up to the first opening
              # and after the last closing paren -- after that, we
              # get the records by simple splitting
              inputLine = inputLine[
                inputLine.index('('):inputLine.rindex(')')]
              for rec in inputLine.split('),('):
                (_, objectid, _, _, ra, dec, magb, magr, lun,
                  redBord, snr, px_x, px_y, pos_ang, ell, sky, fluxes, sp_class
                  ) = [s.strip("'") for s in rec.split(",")]
                yield locals()
          ]]></code>
        </setup>
        <code>
          # The spectra are in one table per source plate, and
          # the dump has the values of one such plate in one line.
          # So, I look for such lines and then parse from there
          with gzip.open(self.sourceToken) as f:
            for line in f:
              if line.startswith("INSERT INTO `fbs"):
                for row in parseSpectraFromDump(line):
                  yield row
        </code>
      </iterator>

      <rowfilter procDef="//products#define">
        <bind name="table">"\schema.spectra"</bind>
        <bind key="accref">"\rdId/%s-%s"%(@plate, @objectid[5:])</bind>
        <bind name="path">makeAbsoluteURL(
          "\rdId/sdl/dlget?ID="+urllib.quote("\rdId/%s-%s"%(
            @plate, @objectid[5:])))</bind>
        <bind name="mime">"application/x-votable+xml"</bind>
        <bind name="preview_mime">"image/png"</bind>
        <bind name="preview">makeAbsoluteURL("\rdId/preview/qp/%s-%s"%(
          @plate, @objectid[5:]))</bind>
        <bind name="fsize">20000</bind>
      </rowfilter>
    </embeddedGrammar>

    <make table="raw_spectra">
      <rowmaker idmaps="*">
        <!-- redBord is an index to where the flux spectrum starts.
        redBord+2 is the 690 nm bin -->
        <var key="flux">[float(item or 'nan')
          for item in @fluxes.split("#")[int(@redBord)+1:]]</var>
        <var key="ra">float(@ra)</var>
        <var key="dec">float(@dec)</var>

        <map key="pos">pgsphere.SPoint.fromDegrees(@ra, @dec)</map>
        <map key="specid">@plate+"-"+@objectid[5:]</map>

        <map key="px_length">len(@flux)</map>
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
    <meta name="_associatedDatalinkService">
      <meta name="serviceId">sdl</meta>
      <meta name="idColumn">ssa_pubDID</meta>
    </meta>
    
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
          'ivo://\getConfig{ivoa}{authority}/~?\rdId/' || specid AS ssa_pubDID,
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
          (lam_min+690e-9)/2. AS ssa_specmid,
          690e-9-lam_min AS ssa_specext,
          lam_min AS ssa_specstart,
          690e-9 AS ssa_specend,
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
    <spatial>2/0,2,8,19-20,40,102,106 3/36-38,40-41,66,73-75,84-86,88-90,96-97,99-100,102,105,117,119,122-123,125-126,129-133,135-137,139,141-145,147-150,152-154,164-165,168-170,181-183,185-190,212,273-277,279-281,285,287,289-290,292-293,295,298-299,309,311,314-315,341,353-355,358,361-364,399,403-404,413-415,419-421,428,430-434,436-438,440,442,444,490-491,507-508,510-511,574-575,639,703,765,767 4/26,48,50,56,58-59,61-63,104-106,156,168-169,172,176,192,215,221-223,244-245,256,258-262,268,270-273,275-277,279,281-282,284-285,287,289,291,348,364,368,383,393,395,404-405,407,412,425,427-428,432-434,447-448,463,467,472-474,483-486,496,498-499,508,512-513,515,536-537,552-553,555,561-563,584,586,604,620,624,639,664,666-667,684,688,703-704,719,723,739,764,768,773,775,784,786-787,789,836-837,839,843-846,852,854,857,868-869,938-939,959,1055,1071,1076-1077,1079-1080,1082-1083,1091,1112-1114,1128-1129,1132-1133,1135-1136,1138-1139,1144-1145,1147,1155,1164-1166,1177,1186,1188,1190-1191,1202-1204,1206-1210,1212-1213,1215,1218,1220-1221,1223-1225,1227,1232,1234-1235,1240-1241,1243,1249-1252,1254-1255,1268-1269,1271-1272,1274-1275,1411,1426,1436,1438-1441,1443,1460,1464,1589-1591,1593-1595,1605-1607,1609-1611,1626-1628,1630-1631,1649-1651,1669-1671,1673-1675,1688,1690,1693,1695,1716,1718,1740-1741,1743,1757,1759,1765-1767,1772,1774,1780-1781,1783,1787,1789-1791,1876-1877,1929-1930,1952,1954-1955,1958,1978-1980,1982-1983,2021-2023,2025-2027,2038,2271,2287,2291-2294,2549-2551,2553,2555,2805-2807,2809-2811,3039,3059,3064-3065,3067 5/64-66,72,74-75,96-98,109-111,120,122,196-198,206,223,228,230-231,243,392,394-395,397-399,410,428,432,434,503,509,511,628-630,632-634,681,684-685,692-694,696-697,708-710,712-714,772,774,776-778,853-855,857,859,877,879,881-883,985,988,1013-1014,1028-1030,1052-1054,1076,1078-1079,1096-1097,1099,1113-1115,1123,1132,1134,1144-1145,1147,1152-1153,1155,1161-1163,1396-1398,1400-1402,1460-1462,1464-1466,1476-1478,1480-1482,1527,1531,1568-1569,1571,1577,1624,1652-1654,1656-1658,1669,1671,1677-1679,1705,1716-1718,1720-1722,1740,1783,1787,1796-1798,1800-1802,1847,1851,1863,1867,1900-1901,1927,1931,1948-1949,1990-1991,2036-2038,2040,2057,2059,2152-2154,2157-2159,2216,2218,2241-2243,2340-2341,2343,2350-2351,2420-2422,2424-2426,2484-2486,2488-2490,2500-2502,2504-2506,2551,2555,2660,2662-2663,2673-2678,2682,2740-2742,2744-2746,2756-2758,2760-2762,2807,2811,2820-2822,2824-2826,2871,2875,2887,2891,2951,2955,3060-3062,3064-3066,3076-3078,3080-3082,3089,3099,3116,3118-3121,3124-3125,3140,3142-3143,3155,3160-3161,3164,3168-3170,3328-3329,3332-3334,3353-3355,3365-3367,3369-3371,3388,3390,3414,3420,3422,3424-3425,3433-3438,3440-3442,3457,3461,3463,3469,3480-3482,3484,3520,3522,3737-3740,3744,3746-3747,3749-3751,3760-3762,3768-3770,3835,4031,4074-4075,4078,4090,4215,4219,4279,4283,4299,4302,4313,4324,4326-4327,4340-4341,4343-4344,4346-4347,4350,4357-4359,4361-4363,4461,4520-4521,4523,4537,4539,4550-4551,4584-4586,4615,4619,4668,4704-4705,4717,4736-4738,4740-4741,4743,4749-4751,4756,4758-4759,4801-4803,4806-4807,4820,4822-4823,4844-4846,4856-4857,4859,4871,4888-4889,4891,4904-4905,4907,4914,4916-4917,4920,4922-4923,4933-4935,4969,5012,5014-5015,5061,5064,5066-5067,5081,5092,5094-5095,5109,5114,5307,5310,5444-5445,5447,5455,5477,5492-5493,5495,5499,5585,5588-5589,5621,5623,5631,5639,5641-5643,5698,5709-5711,5722,5750,5769,5844,5848,5860,5864,5866,5973,5981,5983,6271,6335,6351,6355,6371,6415,6419,6435,6480,6485,6487,6490,6496,6498-6499,6501,6518-6519,6671,6675,6691,6756-6758,6764,6766-6769,6771,6777,6779,6868-6869,6876,6878-6879,6969,7024-7025,7027,7034-7035,7057-7059,7092-7094,7100,7102-7103,7128-7129,7131,7136-7137,7139-7140,7142-7143,7145-7147,7155,7492-7493,7495,7512-7513,7516-7517,7715,7724-7726,7730,7736,7738-7739,7814,7838-7839,7899,7904,7906-7907,7911,7924,7926-7927,7999,8046,8079,8083,8099,8144,8146-8147,8156,8158-8159,8702,9041,9044-9046,9077-9079,9081-9083,9141-9143,9145-9147,9157-9159,9162-9163,9180-9182,10111,10191-10192,10194-10195,10211,10216-10217,10219,11135,11199,11215,11219,11235,12151,12155,12215,12231,12235,12264-12265,12267 6/268-270,272,274,292,294-295,312,314,396,398-400,415,432,434-435,456,458-459,484,486-487,492,796,798,816,818-819,828,830-832,887,891,916,918,967,970-971,1547,1572,1574-1575,1585-1587,1634-1635,1646,1716-1718,1720-1722,1732-1734,1740,1760,2005-2007,2009,2011,2033,2035,2041,2043,2524-2526,2540-2542,2544-2546,2720-2721,2723,2745,2748-2749,2780-2782,2792-2793,2796-2797,2800-2802,2844-2846,2860-2862,2864-2866,2880-2882,2944-2946,3100,3102,3116-3118,3120-3122,3200-3202,3407,3409-3411,3487,3523,3861,3863,3869,3936-3937,3948-3949,3951,3956-3957,3959-3960,3965,3967,4051,4060,4125-4127,4220-4222,4310,4392-4393,4395,4448-4450,4484-4485,4487,4490-4491,4532-4533,4535,4540,4542-4543,4584-4585,4587,4616-4617,4619,4641-4643,5596,5598,5612,5614,5616-5618,5852-5854,5868,5872,5874,5916,5918,5932-5934,5936-5937,5952-5953,6016-6018,6101-6103,6105-6107,6117-6119,6121-6123,6281,6316-6317,6319,6500-6501,6503-6504,6506,6620-6622,6636-6637,6640-6642,6672-6673,6675,6701,6703,6705-6707,6789,6799,6819,6825,6828-6829,6876-6878,6892-6894,6896-6898,6964-6966,6968-6970,6976-6978,6984,6986,7040-7042,7125-7127,7129-7131,7141-7143,7146-7147,7196,7198,7212-7214,7216-7218,7232-7234,7296-7298,7381-7383,7385-7387,7397-7399,7401-7403,7445-7447,7449-7451,7461-7463,7465-7467,7608-7610,7612-7613,7615,7701-7703,7705-7707,7717-7719,7721-7723,7800,7802,7807,7955,7957-7959,8156,8164-8166,8168-8170,8225,8235,8620,8623-8625,8627,8869-8870,8876,8878-8879,8960,8962-8963,9368-9369,9394,9396-9397,9399,9692-9694,9708-9710,9712-9714,9948-9950,9964-9966,9968-9970,10012-10014,10028-10030,10032-10034,10048-10050,10112-10114,10199,10203,10213-10215,10217-10219,10644-10646,10688-10689,10691,10716,10718,10720,10722-10726,10732,10734,10736-10737,10972-10974,10988,10992,10994,11036,11038,11052-11054,11056-11057,11072-11074,11136,11138,11221-11223,11225-11227,11237-11239,11241-11243,11292-11293,11308-11310,11312-11314,11328,11330,11392-11394,11477-11479,11481-11483,11493-11495,11498-11499,11541-11543,11545-11547,11557-11559,11561-11563,11797-11799,11801-11803,11813-11815,11817-11819,12268,12272,12316,12332,12336,12352-12353,12365,12389-12391,12393-12395,12416,12437,12439,12453-12455,12461,12470,12488-12489,12491-12494,12508-12509,12511,12566,12613,12615,12619,12648-12650,12653,12660,12664,12684,12688,12692-12693,12704,12799,12817,12820,13320,13324-13325,13327,13340-13341,13360,13375,13409,13411,13455,13459,13475,13564,13566-13567,13648,13650-13651,13660,13662,13684,13686,13692,13704,13708-13709,13711,13731,13756,13772,13776,13792,13824-13825,13827,13836,13840-13841,13843,13885,13933,13935,13940-13942,13944-13946,14017,14019-14020,14022,14084-14086,14092,14888,14890-14891,14911,14927,14938-14939,14942-14943,14964-14966,14968,14970,14980,14982-14983,15052,15054-15056,15066-15067,15084-15086,15088-15090,15114,15333-15335,15339,16032-16034,16040,16042-16043,16046-16047,16058-16059,16062-16063,16106-16107,16110-16111,16121-16123,16316,16318-16319,16364,16767,16853-16855,16857-16859,16869,16871,16873,16875,17109-17111,17113-17115,17125-17127,17129-17131,17173-17175,17180-17181,17183,17190-17191,17193-17195,17202,17214,17248-17249,17251,17260-17261,17263,17300,17302-17303,17352,17354-17355,17368-17369,17371,17380,17382-17383,17394,17396-17397,17399,17406,17423,17427,17443,17840-17842,17848,17852-17853,17855,18088-18089,18091,18096-18098,18100,18104,18145,18155,18192,18194-18195,18199,18349-18350,18453-18455,18457-18459,18470-18471,18473-18475,18676-18678,18680-18682,18824-18826,18828-18829,18831,18864-18865,18867,18876-18877,18879,18956,18958,18968-18969,18993-18995,19030,19203,19218,19223,19284-19286,19388-19390,19433,19464,19466-19467,19479,19508-19509,19511-19512,19514-19515,19560-19561,19563,19624-19626,19650,19652-19653,19655,19662,19676-19677,19679,19684,19686-19687,19704,19706-19707,19729-19731,19872-19873,19875,19884-19885,19887,19973,19978,19981-19983,20052,20054-20055,20232,20234-20235,20240-20241,20243,20252-20253,20255,20260,20262-20263,20280,20282-20283,20286,20320-20321,20323,20332-20333,20335,20372,20374-20375,20424,20426-20427,20432-20433,20435,20444-20445,20447-20448,20450-20451,20460,20462-20463,21222-21223,21225-21227,21246,21765,21785,21813-21815,21817,21819,21905,21917,21952-21954,21957,21977,21991,21995,22005,22008,22010-22011,22013-22015,22337,22339,22348-22349,22351,22360-22362,22397-22399,22481-22483,22488-22489,22491,22516-22517,22519,22523,22549-22551,22553-22555,22563,22786,22798,22814,22833-22835,22882,22894,22994,23006,23072-23073,23085-23087,23380-23381,23384-23385,23396-23398,23400,23402,23444-23445,23448-23450,23460-23462,23468,23470-23471,23714,23720,23722,23889,23891,23901,23903,23923,23929,24021,25079,25083,25335,25339,25399,25403,25415,25419,25479,25483,25655,25659,25671,25675,25735,25739,25924-25926,25928-25930,25936-25937,25939,25945,25947,25954,25972-25973,25988,25990,26001,26010,26015,26066,26071,26368-26370,26372-26373,26375-26376,26378-26379,26679,26683,26695,26699,26759,26763,27036-27038,27062,27080-27081,27083,27113-27115,27480-27482,27484-27485,27487,27510-27511,27872-27874,27885,27887,28104-28105,28107,28130,28132-28133,28135,28224,28226-28227,28380-28382,28404,28406-28407,28520-28521,28523,28553,28564,28566,28579,28612-28613,28615,28618-28619,29956-29957,29976-29977,29979,30005,30007,30056-30057,30059-30062,30076-30077,30079,30779,30782,30855,30859,30908-30909,30911,30914,30950,31248,31250-31251,31260,31262-31263,31296-31297,31299-31300,31302,31305-31307,31310,31344,31346-31347,31350,31530,31593-31595,31610,31622,31637-31639,31641-31643,31702,31995,32170,32175,32190,32235,32311,32315,32327,32331,32391,32394-32395,32580,32582-32583,32600,32602,32628,32630-32631,34797-34799,34814,36161,36163,36172-36173,36175,36188-36190,36208-36209,36223,36287,36303,36307,36323,36479,36543,36559,36563,36579,36627,36643,36645-36647,36732,36734-36735,40426-40427,40439,40443,40725-40727,40732-40733,40735,40759,40763,40772,40774-40775,40839,40843,40873,44535,44539,44791,44795,44855,44859,44871,44875,44935,44939,48597-48599,48601-48603,48613-48615,48617-48619,48853-48855,48857,48859,48884-48885,48887,48917-48919,48921-48923,48933-48935,48937-48939,49065</spatial>
    <temporal>39165 44374</temporal>
    <spectral>3.126e-07 6.9e-07</spectral>
  </coverage>

  <data id="make_ssa_view" auto="False">
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
    <column name="ra_center"
      ucd="pos.eq.ra" unit="deg"
      tablehead="Center RA"
      description="Center of plate in RA (ICRS)"
      verbLevel="1"/>
    <column name="dec_center"
      ucd="pos.eq.dec" unit="deg"
      tablehead="Center Dec"
      description="Center of plate in Dec (ICRS)"
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
            "QUERY": "select object as plateid, epoch, exptime, emulsion,"
              " raj2000, dej2000"
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
            row["ra_center"] = row["raj2000"]
            row["dec_center"] = row["dej2000"]
            yield row
        </code>
      </iterator>
    </embeddedGrammar>

    <make table="platemeta"/>
  </data>


  <table id="spectra" onDisk="True" adql="hidden">
    <meta name="description">This table contains basic metadata as well
      as the spectra from the Digital First Byurakan Survey (DFBS).
    </meta>
    <LOOP listItems="accref plate specid ra dec pos sp_class px_length
        flux magb magr snr lam_min">
      <events>
        <column original="raw_spectra.\item"/>
      </events>
    </LOOP>
    <LOOP listItems="epoch exptime emulsion">
      <events>
        <column original="platemeta.\item"/>
      </events>
    </LOOP>

    <column name="spectral" type="real[]"
      unit="m" ucd=""
      tablehead="Spectral[]"
      description="Spectral points of the extracted spectrum (wavelengths) 
        as an array (that's actually the same for all spectra and only
        given here as a convenience)."
      verbLevel="30"/>
    <column name="cutout_link" type="text"
    	ucd="meta.ref.url"
    	tablehead="Image"
    	description="Cutout of the image this spectrum was extracted from"
    	verbLevel="15"/>

    <viewStatement>
      CREATE VIEW \curtable AS (
        SELECT \colNames
        FROM (
          SELECT 
            a.*, 
            b.*, 
            '{\spectralBins}'::float[] AS spectral,
          '\getConfig{web}{serverURL}/dfbs/q/dl/dlget?ID=plate/' 
          	|| plate
          	|| '&amp;CIRCLE='
          	|| DEGREES(long(pos)) || ' '
          	|| DEGREES(lat(pos)) || ' 0.02' AS cutout_link
          FROM 
            \schema.raw_spectra as a
            JOIN \schema.platemeta as b
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
    <outputTable
      autoCols="accref,accsize,ssa_location,ssa_dstitle,magr,magb, ssa_snr"/>
  </service>

  <service id="getssa" allowed="ssap.xml,form">
    <meta name="shortName">DFBS SSAP</meta>
    <meta name="title">DFBS Spectra Query Service</meta>
    <meta name="ssap.dataSource">pointed</meta>
    <meta name="ssap.testQuery">MAXREC=1</meta>
    <meta name="ssap.creationType">archival</meta>
    <meta name="ssap.complianceLevel">query</meta>

    <publish sets="ivo_managed" render="ssap.xml"/>
    <publish sets="ivo_managed,local" render="form" service="web"/>
    
    <ssapCore queriedTable="ssa">
      <FEED source="//ssap#hcd_condDescs"/>
    </ssapCore>
  </service>

  <service id="preview" allowed="qp">
    <meta name="title">DFBS spectra preview maker"</meta>
    <property name="queryField">specid</property>
    <pythonCore>
      <inputTable>
        <inputKey name="specid" type="text" required="True"
          description="ID of the spectrum to produce a preview for"/>
      </inputTable>
      <coreProc>
        <setup>
          <code>
            from gavo.helpers.processing import SpectralPreviewMaker
            from gavo import svcs
          </code>
        </setup>
        <code>
          with base.getTableConn() as conn:
            res = list(conn.query("SELECT spectral, flux"
              " FROM \schema.spectra"
              " WHERE specid=%(specid)s",
              inputTable.args))

          if not res:
            raise svcs.UnknownURI("No such spectrum known here")

          return ("image/png", SpectralPreviewMaker.get2DPlot(
            zip(res[0][0], res[0][1]), linear=True))
        </code>
      </coreProc>
    </pythonCore>
  </service>

  <regSuite title="DFBS regression">
    <regTest title="Spectra metadata plausible via SSA">
      <url REQUEST="queryData" POS="29.0426958,20.373625"
        SIZE="0.001">getssa/ssap.xml</url>
      <code>
        row = self.getFirstVOTableRow()
        self.assertEqual(row['ssa_location'].asSODA(),	
          '29.0426958306 20.373624999')
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
      <url ID="ivo://byu.arvo/~?dfbsspec/q/fbs1163-015613.29+201136.2"
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
        WHERE specid='fbs1163-015610.24+202225.0'"
        >/tap/sync</url>
      <code>
        rows = self.getVOTableRows()
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertAlmostEqual(row["lam_min"],  3.2060000e-07)
        self.assertAlmostEqual(row["dec"],  20.373625)
        self.assertEqual(row["emulsion"],  "IIF")
        self.assertAlmostEqual(row["flux"][2], 28.86, 5)
        self.assertAlmostEqual(row["spectral"][0], 6.9e-7)
      </code>
    </regTest>
  </regSuite>

</resource>
<!-- vim:et:sta:sw=2
-->
