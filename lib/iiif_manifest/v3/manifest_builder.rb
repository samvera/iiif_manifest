require_relative 'manifest_builder/iiif_service'
require_relative 'manifest_builder/canvas_builder'
require_relative 'manifest_builder/record_property_builder'
require_relative 'manifest_builder/choice_builder'
require_relative 'manifest_builder/content_builder'
require_relative 'manifest_builder/body_builder'
require_relative 'manifest_builder/structure_builder'
require_relative 'manifest_builder/image_service_builder'

module IIIFManifest
  module V3
    class ManifestBuilder
      attr_reader :work,
                  :builders,
                  :top_record_factory
      def initialize(work, builders:, top_record_factory:)
        @work = work
        @builders = builders
        @top_record_factory = top_record_factory
      end

      def apply(collection)
        collection['manifests'] ||= []
        collection['manifests'] << to_h
        collection
      end

      def to_h
        @to_h ||= builders.new(work).apply(top_record)
      end

      private

        def top_record
          top_record_factory.new
        end
    end
  end
end
