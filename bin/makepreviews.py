from gavo import api

class PreviewMaker(api.SpectralPreviewMaker):
  sdmId = "build_sdm_data"


if __name__=="__main__":
  api.procmain(PreviewMaker, "dfbs/q", "import")
