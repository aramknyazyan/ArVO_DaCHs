<!--
* remaining metadata from spectra
* metadata from source images (dateObs!)
* description, additional service parameters
* coverage profile, creator
* return min and max wavelength in main grammar
* datalink: link to original text file
* regression tests
-->
<resource schema="dfbs">
	<meta name="title">Digitized First Byurakan Survey (DFBS)</meta>
	<meta name="description">
		...
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
		<meta name="profile">AllSky ICRS</meta>
	</meta>

	<table id="data" onDisk="true">
		<mixin
			fluxUnit=" "
			fluxUCD="phot.flux.density"
			spectralUnit="nm">//ssap#mixc</mixin>
		<mixin>//ssap#simpleCoverage</mixin>
		<mixin>//obscore#publishSSAPMIXC</mixin>

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
		<column name="dlurl" type="text"
			tablehead="Datalink URI"
			description="Datalink (more formats, more access options) URL"
			displayHint="type=url"/>
	</table>

	<data id="import">
		<property key="previewDir">previews</property>
		<sources pattern="data/*.spec"/>
		<embeddedGrammar>
			<iterator>
				<setup>
					<code>
						import re
					</code>
				</setup>
				<code>
					res = {}
					with open(self.sourceToken) as f:
						for ln in f:
							if ln.startswith("# "):
								key, value = ln[1:].strip().split(":", 1)
								res[re.sub("[^A-Za-z]+", "", key)] = value.strip()
							elif ln.startswith("## spectral"):
								break
					yield res
				</code>
			</iterator>
			<rowfilter procDef="//products#define">
				<bind name="table">"\schema.data"</bind>
				<bind name="path">makeAbsoluteURL(
					"\rdId/sdl/dlget?ID="+urllib.quote(
						getStandardPubDID(\inputRelativePath{False})))</bind>
				<bind name="mime">"application/x-votable+xml"</bind>
				<bind name="preview_mime">"image/png"</bind>
				<bind name="preview">\standardPreviewPath</bind>
			</rowfilter>
		</embeddedGrammar>

		<make table="data">
			<rowmaker idmaps="ssa_*">
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

				<apply procDef="//ssap#setMeta">
					<bind name="alpha">hmsToDeg(@raJ, ":")</bind>
					<bind name="aperture">2/3600.</bind>
					<bind name="delta">dmsToDeg(@decJ, ":")</bind>
					<bind name="dstitle">"DFBS spectrum "+@objectid</bind>
					<bind name="length">float(@spectrumlength.split()[0])</bind>
					<bind name="pubDID">\standardPubDID</bind>
					<bind name="snr">@snr</bind>
					<bind name="targname">@objectid</bind>
				</apply>
				<apply procDef="//ssap#setMixcMeta">
					<bind name="binSize">50e-10</bind>
					<bind name="collection">"DFBS"</bind>
					<bind name="dataSource">"survey"</bind>
					<bind name="fluxCalib">"UNCALIBRATED"</bind>
					<bind name="specCalib">"ABSOLUTE"</bind>
				</apply>
 
				<map key="dlurl">\dlMetaURI{sdl}</map>
				<map key="magb">@magB</map>
				<map key="magr">@magR</map>
			</rowmaker>
		</make>
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

	<service id="sdl" allowed="dlget,dlmeta">
		<meta name="title">DFBS Datalink Service</meta>

		<datalinkCore>
			<descriptorGenerator procDef="//soda#sdm_genDesc">
				<bind name="ssaTD">"\rdId#data"</bind>
			</descriptorGenerator>
			<dataFunction procDef="//soda#sdm_genData">
				<bind name="builder">"\rdId#build_sdm_data"</bind>
			</dataFunction>
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
		<outputTable autoCols="accref,accsize,ssa_dstitle,magr,magb,dlurl,ssa_snr"/>
	</service>

	<service id="ssa" allowed="ssap.xml">
		<meta name="shortName">DFBS SSAP</meta>
		<meta name="ssap.dataSource">pointed</meta>
		<meta name="ssap.testQuery">MAXREC=1</meta>
		<meta name="ssap.creationType">archival</meta>
		<meta name="ssap.complianceLevel">query</meta>

		<ssapCore queriedTable="data">
			<FEED source="//ssap#hcd_condDescs"/>
		</ssapCore>
	</service>
</resource>
