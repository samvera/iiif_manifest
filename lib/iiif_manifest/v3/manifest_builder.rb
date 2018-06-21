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

      # Utility method to wrap the obj into a IIIF V3 compliant language map as needed.
      def self.language_map(obj)
        # self.valid_language_map?(obj) ? obj : self.transform(obj)
        obj.is_a?(Hash) ? transform_hash_value(obj) : transform_obj_value(obj)
      end

      private_class_method
        def self.transform_obj_value(obj)
          { '@none' => Array(obj) }
        end

        def self.transform_hash_value(hash)
          { hash['@language'] => Array(hash['@value']) }
        end

      private

        # # Returns true if obj is a valid IIIF language map; false otherwise
        # def self.valid_language_map?(obj)
        #   obj.is_a?(Hash) && obj['@language'].is_a?(Array)
        # end
        #
        # def self.transform(obj)
        #   obj.is_a?(Array) ? { '@none' => Array(obj) } : { '@none' => Array.new(1, obj) }
        # end

        def top_record
          top_record_factory.new
        end
    end
  end
end
