module IIIFManifest::V3
  class ManifestBuilder
    class CanvasBuilder < ::IIIFManifest::ManifestBuilder::CanvasBuilder
      def apply(items)
        return items if canvas.items.blank?
        items += [canvas]
      end

      private

      def apply_record_properties
        canvas['id'] = path
        canvas.label = record.to_s
      end
    end
  end
end
