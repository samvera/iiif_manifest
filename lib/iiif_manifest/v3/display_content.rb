module IIIFManifest
  module V3
    class DisplayContent
      attr_reader :url, :width, :height, :duration, :iiif_endpoint, :format, :type,
                  :label, :auth_service, :thumbnail
      def initialize(url, type:, width: nil, height: nil, duration: nil, label: nil,
                     format: nil, iiif_endpoint: nil, auth_service: nil, thumbnail: nil)
        @url = url
        @type = type
        @width = width
        @height = height
        @duration = duration
        @label = label
        @format = format
        @iiif_endpoint = iiif_endpoint
        @auth_service = auth_service
        @thumbnail = thumbnail
      end
    end
  end
end
