module IIIFManifest
  module V3
    class SupplementingContent
      attr_reader :url, :type, :format, :language, :label

      def initialize(url, type:, **kwargs)
        @url = url
        @type = type
        @format = kwargs[:format]
        @language = kwargs[:language]
        @label = kwargs[:label]
      end
    end
  end
end
