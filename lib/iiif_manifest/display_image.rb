module IIIFManifest
  class DisplayImage
    attr_reader :url, :type, :width, :height, :iiif_endpoint, :format
    def initialize(url, width:, height:, format: nil, iiif_endpoint: nil)
      @url = url
      @type = 'Image'
      @width = width
      @height = height
      @format = format
      @iiif_endpoint = iiif_endpoint
    end
  end
end
