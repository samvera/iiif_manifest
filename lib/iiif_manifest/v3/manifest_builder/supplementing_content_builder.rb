module IIIFManifest
  module V3
    class ManifestBuilder
      class SupplementingContentBuilder
        attr_reader :supplementing_content, :iiif_annotation_factory, :body_builder_factory
        def initialize(supplementing_content, iiif_annotation_factory:, body_builder_factory:)
          @supplementing_content = supplementing_content
          @iiif_annotation_factory = iiif_annotation_factory
          @body_builder_factory = body_builder_factory
          build_supplementing_resource
        end

        def apply(canvas)
          # Assume first item in canvas annotations is an annotation page
          supplementing_annotation['id'] = "#{canvas.annotations.first['id']}/annotations/#{supplementing_annotation.index}"
          supplementing_annotation['target'] = canvas['id']
          supplementing_annotation['motivation'] = 'supplementing'
          supplementing_annotation
        end

        private

        def build_supplementing_resource
          supplementing_body_builder.apply(supplementing_annotation)
        end

        def supplementing_body_builder
          body_builder_factory.new(supplementing_content)
        end

        def supplementing_annotation
          @supplementing_annotation ||= iiif_annotation_factory.new
        end
      end
    end
  end
end
