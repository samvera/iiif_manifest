module IIIFManifest
  class ManifestBuilder
    class ImageServiceBuilder
      attr_reader :iiif_endpoint
      def initialize(iiif_endpoint)
        @iiif_endpoint = iiif_endpoint
      end

      def apply(resource)
        service['@context'] = iiif_endpoint.context
        service['@id'] = iiif_endpoint.url
        service['profile'] = iiif_endpoint.profile
        resource.service = service
      end

      private

        def service
          @service ||= IIIF::Service.new
        end
    end
  end
end
