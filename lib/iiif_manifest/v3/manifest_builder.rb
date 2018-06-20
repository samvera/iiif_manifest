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

      # TODO issue #116: what if obj is already a lang map?
      # Utility method to wrap the give obj into a IIIF V3 compliant language map as needed.
      def self.language_map(obj)
        (obj.is_a?(Hash) && obj['@language']) ? self.transform_hash_value(obj) : self.transform_obj_value(obj)
      end

      # Returns true if obj is a valid IIIF language map; false otherwise
      def valid_language_map(obj)
        obj.is_a?(Hash) && obj['@language'] && obj['@language']
      end

      def self.transform_obj_value(obj)
        { '@none' => Array(obj) }
      end

      def self.transform_hash_value(hash)
        { hash['@language'] => Array(hash['@value']) }
      end

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
