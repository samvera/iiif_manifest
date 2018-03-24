module IIIFManifest::V3
  class ManifestBuilder
    class RecordPropertyBuilder < ::IIIFManifest::ManifestBuilder::RecordPropertyBuilder
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
        manifest
      end
      # rubocop:enable Metrics/AbcSize

      def populate_rendering
        if record.respond_to?(:sequence_rendering)
          record.sequence_rendering.each(&:to_h)
        else
          []
        end
      end
    end
  end
end
