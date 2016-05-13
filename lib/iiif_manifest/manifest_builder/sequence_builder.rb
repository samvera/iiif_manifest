module IIIFManifest
  class ManifestBuilder
    class SequenceBuilder
      attr_reader :work, :canvas_builder_factory
      def initialize(work, canvas_builder_factory:)
        @work = work
        @canvas_builder_factory = canvas_builder_factory
      end

      def apply(manifest)
        # sequence.viewing_hint = manifest.viewing_hint
        manifest.sequences += [sequence] unless empty?
        manifest
      end

      def empty?
        sequence.canvases.empty?
      end

      private

        def canvas_builder
          canvas_builder_factory.from(work)
        end

        def sequence
          @sequence ||=
            begin
              sequence = IIIF::Presentation::Sequence.new
              sequence["@id"] ||= work.manifest_url + "/sequence/normal"
              canvas_builder.apply(sequence)
              sequence
            end
        end
    end
  end
end
