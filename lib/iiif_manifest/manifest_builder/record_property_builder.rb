module IIIFManifest
  class ManifestBuilder
    class RecordPropertyBuilder
      attr_reader :record, :path
      def initialize(record)
        @record = record
      end

      # rubocop:disable Metrics/AbcSize
      def apply(manifest)
        manifest['@id'] = record.manifest_url.to_s
        manifest.label = record.to_s
        manifest.description = record.description
        manifest.viewing_hint = viewing_hint if viewing_hint.present?
        manifest.viewing_direction = viewing_direction if viewing_direction.present?
        manifest.metadata = record.manifest_metadata if valid_metadata?
        manifest
      end
      # rubocop:enable Metrics/AbcSize

      private

      def viewing_hint
        (record.respond_to?(:viewing_hint) && record.send(:viewing_hint))
      end

      def viewing_direction
        (record.respond_to?(:viewing_direction) && record.send(:viewing_direction))
      end

      # Validate manifest_metadata against the IIIF spec format for metadata
      #
      # @return [Boolean]
      def valid_metadata?
        return false unless record.respond_to?(:manifest_metadata)
        metadata = record.manifest_metadata
        valid_metadata_structure?(metadata) && valid_metadata_content?(metadata)
      end

      # Manifest metadata must be an array containing hashes
      #
      # @param metadata [Array<Hash>] a list of metadata with label and value as required keys for each entry
      # @return [Boolean]
      def valid_metadata_structure?(metadata)
        metadata.is_a?(Array) && metadata.all? { |v| v.is_a?(Hash) }
      end

      # Manifest Metadata Hashes must contain 'label' and 'value' keys
      #
      # @param metadata [Array<Hash>] a list of metadata with label and value as required keys for each entry
      # @return [Boolean]
      def valid_metadata_content?(metadata)
        metadata.all? { |v| v['label'].present? && v['value'].present? }
      end
    end
  end
end
