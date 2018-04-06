module IIIFManifest
  module V3
    class ManifestBuilder
      class BodyBuilder
        attr_reader :display_content, :iiif_body_factory, :image_service_builder_factory
        def initialize(display_content, iiif_body_factory:, image_service_builder_factory:)
          @display_content = display_content
          @iiif_body_factory = iiif_body_factory
          @image_service_builder_factory = image_service_builder_factory
        end

        def apply(annotation)
          build_body
          image_service_builder.apply(body) if iiif_endpoint
          annotation.body = body
        end

        private

        def build_body
          body['id'] = display_content.url
          body['type'] = body_type
          body['height'] = display_content.height if display_content.try(:height)
          body['width'] = display_content.width if display_content.try(:width)
          body['duration'] = display_content.duration if display_content.try(:duration)
          body['format'] = display_content.format if display_content.format
          body['label'] = display_content.label if display_content.try(:label)
        end

        def body
          @body ||= iiif_body_factory.new
        end

        def body_type
          display_content.try(:type) || 'Image'
        end

        def iiif_endpoint
          display_content.try(:iiif_endpoint)
        end

        def image_service_builder
          image_service_builder_factory.new(iiif_endpoint)
        end
      end
    end
  end
end
