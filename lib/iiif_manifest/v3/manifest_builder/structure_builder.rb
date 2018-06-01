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
          range_items.map do |range_item|
            if range_item.nil?
              next
            elsif range_item.is_a? Hash
              range['items'] << range_item
            else
              range_item.apply(range['items'])
            end
          end
          manifest
        end

        def build_range
          range['id'] = path
          range['label'] = record.label
          range['behavior'] = 'top' if top?
          range['items'] = canvas_builders.collect { |cb| { 'type' => 'Canvas', 'id' => cb.path } }
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

        def range_items
          @range_items ||= record.items.map do |range_item|
            # Determine if this item is a range or canvas
            if range_item.respond_to? :id
              canvas_builder = canvas_builder_factory.new(range_item, parent)
              { 'type' => 'Canvas', 'id' => canvas_builder.path }
            elsif range_item.respond_to? :label
              RangeBuilder.new(
                range_item,
                parent,
                canvas_builder_factory: canvas_builder_factory,
                iiif_range_factory: iiif_range_factory
              )
            else
              nil # Throw an error?
            end
          end
        end
      end
    end
  end
end
