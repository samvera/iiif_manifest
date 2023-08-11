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
          generic_annotation['id'] = annotation_id(canvas_id)
          generic_annotation['target'] = target(canvas)
          generic_annotation['motivation'] = motivation
          generic_annotation
        end

        private

        def build_annotation_resource
          annotation_body_builder.apply(generic_annotation)
        end

        def annotation_body_builder
          body_builder_factory.new(annotation_content)
        end

        def generic_annotation
          @generic_annotation ||= iiif_annotation_factory.new
        end

        def annotation_id(canvas_id)
          if annotation_content.try(:annotation_id).blank?
            "#{canvas_id}/#{motivation}/#{generic_annotation.index}"
          else
            annotation_content.annotation_id
          end
        end

        def motivation
          annotation_content.motivation if annotation_content.try(:motivation).present?
        end

        def target(canvas)
          if annotation_content.try(:media_fragment).present?
            canvas['id'] + "##{annotation_content.media_fragment}"
          else
            canvas['id']
          end
        end
      end
    end
  end
end
