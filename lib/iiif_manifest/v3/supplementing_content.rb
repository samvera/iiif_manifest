module IIIFManifest
  module V3
    class SupplementingContent
      attr_reader :url, :type, :motivation, :format, :language, :label, :value, :media_fragment

      def initialize(url, type:, motivation: 'supplementing', **kwargs)
        @url = url
        @type = type
        @motivation = motivation
        @format = kwargs[:format]
        @language = kwargs[:language]
        @label = kwargs[:label]
        @value = kwargs[:value]
        @media_fragment = kwargs[:media_fragment]
      end
    end
  end
end
