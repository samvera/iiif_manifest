module IIIFManifest
  module V3
    class ManifestBuilder
      class AnnotationContentBuilder
        attr_reader :annotation_content, :iiif_annotation_factory, :body_builder_factory
        def initialize(annotation_content, iiif_annotation_factory:, body_builder_factory:)
          @annotation_content = annotation_content
          @iiif_annotation_factory = iiif_annotation_factory
          @body_builder_factory = body_builder_factory
          build_annotation_resource
        end

        def apply(canvas)
          # Assume first item in canvas annotations is an annotation page
          canvas_id = canvas.annotations.first['id']
          annotation['id'] = "#{canvas_id}/annotations/#{annotation.index}"
          annotation['target'] = target
          annotation['motivation'] = annotation_content.motivation
          annotation
        end

        private

        def build_annotation_resource
          annotation_body_builder.apply(annotation)
        end

        def body_builder
          body_builder_factory.new(annotation_content)
        end

        def annotation
          @annotation ||= iiif_annotation_factory.new
        end

        def target
          if annotation_content.media_fragment
            canvas['id'] + annotation_content.media_fragment
          else
            canvas['id']
          end
        end
      end
    end
  end
end
