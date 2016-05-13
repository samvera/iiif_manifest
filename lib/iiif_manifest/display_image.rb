module IIIFManifest
  class DisplayImage
    attr_reader :url, :width, :height, :iiif_endpoint, :format
    def initialize(url, width:, height:, format: nil, iiif_endpoint: nil)
      @url = url
      @width = width
      @height = height
      @format = format
      @iiif_endpoint = iiif_endpoint
    end
  end
end
