module IIIFManifest
  module V3
    class ManifestBuilder
      class ThumbnailBuilder
        def initialize(display_content, iiif_thumbnail_factory:, image_service_builder_factory:)
          @display_content = display_content
          @iiif_thumbnail_factory = iiif_thumbnail_factory
          @image_service_builder_factory = image_service_builder_factory
        end

        def apply(canvas)
        end
      end
    end
  end
end
