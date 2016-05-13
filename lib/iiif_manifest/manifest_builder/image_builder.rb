module IIIFManifest
  class ManifestBuilder
    class ImageBuilder
      attr_reader :display_image
      def initialize(display_image)
        @display_image = display_image
        build_resource
      end

      def apply(canvas)
        annotation['on'] = canvas['@id']
        canvas['width'] = annotation.resource['width']
        canvas['height'] = annotation.resource['height']
        canvas.images << annotation
      end

      private

        def build_resource
          resource_builder.apply(annotation)
        end

        def resource_builder
          ResourceBuilder.new(display_image)
        end

        def annotation
          @annotation ||= IIIF::Presentation::Annotation.new
        end
    end
  end
end
