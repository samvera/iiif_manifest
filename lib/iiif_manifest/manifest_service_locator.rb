module IIIFManifest
  class ManifestServiceLocator
    class << self
      def collection_manifest_builder
        InjectedFactory.new(
          ManifestBuilder,
          builders: collection_manifest_builders,
          top_record_factory: iiif_collection_factory
        )
      end

      def manifest_builder
        InjectedFactory.new(
          ManifestBuilder,
          builders: manifest_builders,
          top_record_factory: iiif_manifest_factory
        )
      end

      def child_manifest_builder
        InjectedFactory.new(
          ManifestBuilder,
          builders: record_property_builder,
          top_record_factory: iiif_manifest_factory
        )
      end

      def sammelband_manifest_builder
        InjectedFactory.new(
          ManifestBuilder,
          builders: sammelband_manifest_builders,
          top_record_factory: iiif_manifest_factory
        )
      end

      # Builders which receive a work as an argument to .new and return objects
      #   that respond to #apply.
      def manifest_builders
        composite_builder_factory.new(
          record_property_builder,
          sequence_builder,
          composite_builder: composite_builder
        )
      end

      def sammelband_manifest_builders
        composite_builder_factory.new(
          record_property_builder,
          sammelband_sequence_builder,
          composite_builder: composite_builder
        )
      end

      def collection_manifest_builders
        composite_builder_factory.new(
          record_property_builder,
          child_manifest_builder_factory,
          composite_builder: composite_builder
        )
      end

      def child_manifest_builder_factory
        ManifestBuilder::ChildManifestBuilderFactory.new(
          composite_builder: composite_builder,
          child_manifest_builder: child_manifest_builder
        )
      end

      def iiif_collection_factory
        IIIF::Presentation::Collection
      end

      def composite_builder
        ManifestBuilder::CompositeBuilder
      end

      def composite_builder_factory
        ManifestBuilder::CompositeBuilderFactory
      end

      def record_property_builder
        ManifestBuilder::RecordPropertyBuilder
      end

      def sequence_builder
        InjectedFactory.new(
          ManifestBuilder::SequenceBuilder,
          canvas_builder_factory: canvas_builder_factory
        )
      end

      def sammelband_sequence_builder
        InjectedFactory.new(
          ManifestBuilder::SequenceBuilder,
          canvas_builder_factory: deep_canvas_builder_factory
        )
      end

      def canvas_builder_factory
        ManifestBuilder::CanvasBuilderFactory.new(
          composite_builder: composite_builder,
          canvas_builder_factory: canvas_builder
        )
      end

      def deep_canvas_builder_factory
        ManifestBuilder::DeepCanvasBuilderFactory.new(
          composite_builder: composite_builder,
          canvas_builder_factory: canvas_builder
        )
      end

      def canvas_builder
        ManifestBuilder::CanvasBuilder
      end

      def iiif_manifest_factory
        IIIF::Presentation::Manifest
      end
    end

    class InjectedFactory
      attr_reader :factory, :hash_args
      def initialize(factory, hash_args)
        @hash_args = hash_args
        @factory = factory
      end

      def new(*args)
        factory.new(*args, hash_args)
      end
    end
  end
end
