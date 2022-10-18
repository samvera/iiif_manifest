module IIIFManifest
  class ManifestBuilder
    class CanvasBuilderFactory
      attr_reader :composite_builder, :canvas_builder_factory
      def initialize(composite_builder:, canvas_builder_factory:)
        @composite_builder = composite_builder
        @canvas_builder_factory = canvas_builder_factory
      end

      def from(work, *manifest)
        composite_builder.new(
          *file_set_presenters(work).map do |presenter|
            canvas_builder_factory.new(presenter, work, manifest.first)
          end
        )
      end

      private

      def file_set_presenters(work)
        work.file_set_presenters
      end
    end
  end
end
