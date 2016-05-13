module IIIFManifest
  class ManifestBuilder
    class CanvasBuilder
      attr_reader :record, :parent

      def initialize(record, parent)
        @record = record
        @parent = parent
        apply_record_properties
        attach_image if display_image
      end

      def canvas
        @canvas ||= IIIF::Presentation::Canvas.new
      end

      def path
        "#{parent.manifest_url}/canvas/#{record.id}"
      end

      def apply(sequence)
        return sequence if canvas.images.blank?
        sequence.canvases += [canvas]
        sequence
      end

      private

        def display_image
          record.display_image if record.respond_to?(:display_image)
        end

        def apply_record_properties
          canvas['@id'] = path
          canvas.label = record.to_s
        end

        def attach_image
          ImageBuilder.new(display_image).apply(canvas)
        end
    end
  end
end
