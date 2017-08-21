module IIIFManifest
  class ManifestBuilder
    class RecordPropertyBuilder
      attr_reader :record, :path
      def initialize(record)
        @record = record
      end

      def apply(manifest)
        manifest['@id'] = record.manifest_url.to_s
        manifest.label = record.to_s
        manifest.description = record.description
        manifest.viewing_hint = viewing_hint if viewing_hint.present?
        manifest
      end

      private

      def viewing_hint
        (record.respond_to?(:viewing_hint) && record.send(:viewing_hint))
      end
    end
  end
end
