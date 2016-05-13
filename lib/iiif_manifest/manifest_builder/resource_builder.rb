module IIIFManifest
  class ManifestBuilder
    class ResourceBuilder
      attr_reader :display_image
      def initialize(display_image)
        @display_image = display_image
      end

      def apply(annotation)
        resource['@id'] = display_image.url
        resource['@type'] = 'dctypes:Image'
        resource['height'] = display_image.height
        resource['width'] = display_image.width
        resource['format'] = display_image.format
        image_service_builder.apply(resource) if iiif_endpoint
        annotation.resource = resource
      end

      private

        def resource
          @resource ||= IIIF::Presentation::Resource.new
        end

        def iiif_endpoint
          display_image.try(:iiif_endpoint)
        end

        def image_service_builder
          ImageServiceBuilder.new(iiif_endpoint)
        end
    end
  end
end
