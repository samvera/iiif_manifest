module IIIFManifest
  module V3
    class ManifestBuilder
      class SupplementingBodyBuilder
        attr_reader :supplementing_content, :iiif_body_factory
        def initialize(supplementing_content, iiif_body_factory:)
          @supplementing_content = supplementing_content
          @iiif_body_factory = iiif_body_factory
        end

        def apply(supplementing_annotation)
          build_supplementing_body
          supplementing_annotation.body = supplementing_body
        end

        private

        def build_supplementing_body
          supplementing_body['id'] = supplementing_content.url
          supplementing_body['type'] = supplementing_content.try(:type) || 'Text'
          supplementing_body['format'] = supplementing_content.format if supplementing_content.try(:format).present?
          supplementing_body['label'] = supplement_label
          supplementing_body['language'] = supplementing_content.try(:language) || 'eng'
        end

        def supplementing_body
          @supplementing_body ||= iiif_body_factory.new
        end

        def supplement_label
          return if supplementing_content.try(:label).blank?
          ManifestBuilder.language_map(supplementing_content.label)
        end
      end
    end
  end
end
