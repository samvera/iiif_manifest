module IIIFManifest
  module V3
    class ManifestBuilder
      class StructureBuilder < ::IIIFManifest::ManifestBuilder::StructureBuilder
        def range_builder(top_range)
          RangeBuilder.new(
            top_range,
            record, true,
            canvas_builder_factory: canvas_builder_factory,
            iiif_range_factory: iiif_range_factory
          )
        end
      end
      class RangeBuilder < ::IIIFManifest::ManifestBuilder::RangeBuilder
        def apply(manifest)
          manifest << range
          sub_ranges.map do |sub_range|
            sub_range.apply(range['items'])
          end
          manifest
        end

        def build_range
          range['id'] = path
          range['label'] = record.label
          range['behavior'] = 'top' if top?
          range['items'] = canvas_builders.collect { |cb| { 'id' => cb.path, 'type' => 'Canvas' } }
        end

        def sub_ranges
          @sub_ranges ||= record.ranges.map do |sub_range|
            RangeBuilder.new(
              sub_range,
              parent,
              canvas_builder_factory: canvas_builder_factory,
              iiif_range_factory: iiif_range_factory
            )
          end
        end
      end
    end
  end
end
