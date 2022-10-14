module IIIFManifest
  module V3
    class ManifestBuilder
      class ThumbnailBuilder
        attr_reader :display_content, :iiif_thumbnail_factory, :image_service_builder_factory
        def initialize(display_content, iiif_thumbnail_factory:, image_service_builder_factory:)
          @display_content = display_content
          @iiif_thumbnail_factory = iiif_thumbnail_factory
          @image_service_builder_factory = image_service_builder_factory
        end

        # @return [Array<Object>]
        def build
          build_thumbnail
          image_service_builder.apply(thumbnail)
          [thumbnail]
        end

        private

        def build_thumbnail
          thumbnail['id'] = File.join(display_content.iiif_endpoint.url, 'full', '!200,200', '0', 'default.jpg')
          thumbnail['height'] = (display_content.height * reduction_ratio).round
          thumbnail['width'] = (display_content.width * reduction_ratio).round
          thumbnail['format'] = display_content.format
        end

        def reduction_ratio
          width = display_content.width
          height = display_content.height
          max_edge = 200.0
          return 1 if width <= max_edge && height <= max_edge

          long_edge = [height, width].max
          max_edge / long_edge
        end

        def thumbnail
          @thumbnail ||= iiif_thumbnail_factory.new
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
