module IIIFManifest
  module V3
    class ManifestBuilder
      class ContentBuilder
        attr_reader :display_content, :iiif_annotation_factory, :body_builder_factory
        def initialize(display_content, iiif_annotation_factory:, body_builder_factory:)
          @display_content = display_content
          @iiif_annotation_factory = iiif_annotation_factory
          @body_builder_factory = body_builder_factory
          build_resource
        end

        def apply(canvas)
          annotation['target'] = canvas['id']
          canvas['width'] = annotation.body['width']
          canvas['height'] = annotation.body['height']
          canvas['duration'] = annotation.body['duration']
          # Assume first item in canvas is an annotation page
          canvas.items.first.items += [annotation]
        end

        private

          def build_resource
            body_builder.apply(annotation)
          end

          def body_builder
            body_builder_factory.new(display_content)
          end

          def annotation
            @annotation ||= iiif_annotation_factory.new
          end
      end
    end
  end
end
