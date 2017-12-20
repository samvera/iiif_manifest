module IIIFManifest
  # IIIF Search Endpoint for http://iiif.io/api/search/1.0
  # Intended to be used to populate a service description it an IIIF Presentation Manifest
  #   see http://iiif.io/api/search/1.0/#service-description
  # Univeral Viewer supports version 0 only (the search box will not show otherwise):
  #   see http://ronallo.com/iiif-workshop/search/service-in-manifest.html
  #   see https://github.com/UniversalViewer/universalviewer/blob/master/src/lib/manifesto.js
  class IIIFSearchEndpoint
    attr_reader :url, :label, :version
    def initialize(url, label: 'Search within this manifest', version: '0')
      @url = url
      @label = label
      @version = version
    end

    def profile
      "http://iiif.io/api/search/#{version}/search"
    end

    def context
      "http://iiif.io/api/search/#{version}/context.json"
    end
  end
end
