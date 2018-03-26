module IIIFManifest::V3
  class ManifestBuilder
    class RecordPropertyBuilder < ::IIIFManifest::ManifestBuilder::RecordPropertyBuilder
      attr_reader :canvas_builder_factory
      def initialize(record, iiif_search_service_factory:, iiif_autocomplete_service_factory:, canvas_builder_factory:)
        super(record, iiif_search_service_factory: iiif_search_service_factory, iiif_autocomplete_service_factory: iiif_autocomplete_service_factory)
        @canvas_builder_factory = canvas_builder_factory
      end

      # rubocop:disable Metrics/AbcSize
      def apply(manifest)
        manifest['id'] = record.manifest_url.to_s
        manifest.label = record.to_s
        manifest.summary = record.description
        manifest.behavior = viewing_hint if viewing_hint.present?
        manifest.viewing_direction = viewing_direction if viewing_direction.present?
        manifest.metadata = record.manifest_metadata if valid_metadata?
        manifest.service = services if search_service.present?
        manifest.rendering = populate_rendering
        # Build the items array
        canvas_builder.apply(manifest.items)
        manifest
      end
      # rubocop:enable Metrics/AbcSize

      def populate_rendering
        if record.respond_to?(:sequence_rendering)
          record.sequence_rendering.collect do |rendering|
            sequence_rendering = rendering.to_h.except('@id')
            sequence_rendering['id'] = rendering['@id']
            sequence_rendering
          end
        else
          []
        end
      end

      private

      def canvas_builder
        canvas_builder_factory.from(record)
      end
    end
  end
end
