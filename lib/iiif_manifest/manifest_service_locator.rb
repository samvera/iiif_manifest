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
          structure_builder,
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

      def structure_builder
        InjectedFactory.new(
          ManifestBuilder::StructureBuilder,
          canvas_builder_factory: canvas_builder,
          iiif_range_factory: iiif_range_factory
        )
      end

      def sequence_builder
        InjectedFactory.new(
          ManifestBuilder::SequenceBuilder,
          canvas_builder_factory: canvas_builder_factory,
          sequence_factory: sequence_factory
        )
      end

      def sammelband_sequence_builder
        InjectedFactory.new(
          ManifestBuilder::SequenceBuilder,
          canvas_builder_factory: deep_canvas_builder_factory,
          sequence_factory: sequence_factory
        )
      end

      def sequence_factory
        IIIF::Presentation::Sequence
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
        InjectedFactory.new(
          ManifestBuilder::CanvasBuilder,
          iiif_canvas_factory: iiif_canvas_factory,
          image_builder: image_builder
        )
      end

      def image_builder
        InjectedFactory.new(
          ManifestBuilder::ImageBuilder,
          iiif_annotation_factory: iiif_annotation_factory,
          resource_builder_factory: resource_builder_factory
        )
      end

      def resource_builder_factory
        InjectedFactory.new(
          ManifestBuilder::ResourceBuilder,
          iiif_resource_factory: iiif_resource_factory,
          image_service_builder_factory: image_service_builder_factory
        )
      end

      def image_service_builder_factory
        InjectedFactory.new(
          ManifestBuilder::ImageServiceBuilder,
          iiif_service_factory: iiif_service_factory
        )
      end

      def iiif_service_factory
        IIIF::Service
      end

      def iiif_resource_factory
        IIIF::Presentation::Resource
      end

      def iiif_annotation_factory
        IIIF::Presentation::Annotation
      end

      def iiif_manifest_factory
        IIIF::Presentation::Manifest
      end

      def iiif_canvas_factory
        IIIF::Presentation::Canvas
      end

      def iiif_range_factory
        IIIF::Presentation::Range
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
