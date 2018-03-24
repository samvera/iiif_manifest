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
        manifest
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
