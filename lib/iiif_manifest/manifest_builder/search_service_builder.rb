module IIIFManifest
  class ManifestBuilder
    # IIIF Search Service Builder
    # Creates a service description for use in an IIIF Presenation Manifest
    #   see http://iiif.io/api/search/1.0/#service-description
    class SearchServiceBuilder
      attr_reader :iiif_search_endpoint, :iiif_service_factory
      def initialize(iiif_search_endpoint, iiif_service_factory:)
        @iiif_search_endpoint = iiif_search_endpoint
        @iiif_service_factory = iiif_service_factory
      end

      def apply(resource)
        apply_to_service
        resource.service << service
      end

      def apply_to_service
        service['@context'] = iiif_search_endpoint.context
        service['@id'] = iiif_search_endpoint.url
        service['profile'] = iiif_search_endpoint.profile
        service['label'] = iiif_search_endpoint.label
      end

      private

      def service
        @service ||= iiif_service_factory.new
      end
    end
  end
end
