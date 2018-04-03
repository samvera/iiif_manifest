module IIIFManifest
  module V3
    class DisplayContent
      attr_reader :url, :width, :height, :duration, :iiif_endpoint, :format
      def initialize(url, type:, width:, height:, duration:, label:, format: nil, iiif_endpoint: nil)
        @url = url
        @type = type
        @width = width
        @height = height
        @duration = duration
        @label = label
        @format = format
        @iiif_endpoint = iiif_endpoint
      end
    end
  end
end
