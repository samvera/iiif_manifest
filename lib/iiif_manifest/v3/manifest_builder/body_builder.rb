module IIIFManifest
  module V3
    class ManifestBuilder
      class BodyBuilder
        attr_reader :content, :iiif_body_factory, :image_service_builder_factory
        def initialize(content, iiif_body_factory:, image_service_builder_factory:)
          @content = content
          @iiif_body_factory = iiif_body_factory
          @image_service_builder_factory = image_service_builder_factory
        end

        def apply(annotation)
          build_body
          image_service_builder.apply(body) if iiif_endpoint
          apply_auth_service if auth_service
          annotation.body = body
        end

        private

        def build_body
          body['id'] = content.url
          body['type'] = body_type
          body_display_dimensions
          body['format'] = content.format if content.try(:format).present?
          body['label'] = ManifestBuilder.language_map(content.label) if content.try(:label).present?
          body['language'] = content.language if content.try(:language).present?
          body['value'] = content.value if content.try(:value).present?
        end

        def body
          @body ||= iiif_body_factory.new
        end

        def body_type
          content.try(:type) || 'Image'
        end

        def body_display_dimensions
          body['height'] = content.height if content.try(:height).present?
          body['width'] = content.width if content.try(:width).present?
          body['duration'] = content.duration if content.try(:duration).present?
        end

        def iiif_endpoint
          content.try(:iiif_endpoint)
        end

        def image_service_builder
          image_service_builder_factory.new(iiif_endpoint)
        end

        def auth_service
          content.try(:auth_service)
        end

        def apply_auth_service
          body.service = if body['service'].blank?
                           [auth_service]
                         else
                           body['service'] + [auth_service]
                         end
        end
      end
    end
  end
end
