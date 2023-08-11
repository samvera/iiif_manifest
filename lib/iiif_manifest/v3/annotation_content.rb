module IIIFManifest
  module V3
    class AnnotationContent
      attr_reader :annotation_id, :body_id, :type, :motivation, :format, :language, :label, :value, :media_fragment

      def initialize(type:, motivation:, **kwargs)
        # If a user requires a specific ID at the annotation level, this attr overrides
        # the automatic ID creation.
        @annotation_id = kwargs[:annotation_id]
        # Body level ids are only required for annotations delivering content,
        # such as a transcript/caption file or an annotation containing an image.
        @body_id = kwargs[:body_id]
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
