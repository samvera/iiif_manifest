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
        manifest.viewing_hint = viewing_hint
        manifest
        # manifest.try(:viewing_direction=, viewing_direction)
      end

      private

        def viewing_hint
          (record.respond_to?(:viewing_hint) && record.send(:viewing_hint)) || 'individuals'
        end

      # def viewing_direction
      #   record.try(:viewing_direction) || "left-to-right"
      # end
      #
      # def viewing_hint
      #   record.viewing_hint || "individuals"
      # end
    end
  end
end
