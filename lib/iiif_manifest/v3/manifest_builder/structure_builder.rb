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
            next if range_item.nil?
            if range_item.is_a? Hash
              range['items'] << range_item
            else
              range_item.apply(range['items'])
            end
          end
          manifest
        end

        def build_range
          range['id'] = path
          range['label'] = ManifestBuilder.language_map(record.label) if record.try(:label).present?
          range['behavior'] = 'top' if top?
          if record.respond_to?(:file_set_presenters)
            range['items'] = record.file_set_presenters.collect { |fs| { 'type' => 'Canvas', 'id' => build_canvas_id(fs) } }
          else
            range['items'] = []
          end
        end

        def canvas_builders
          @canvas_builders ||= [] unless record.respond_to?(:file_set_presenters)
          @canvas_builders ||= file_set_presenters.map do |file_set_presenter|
            canvas_builder_factory.new(file_set_presenter, parent)
          end
          @canvas_builders
        end

        def sub_ranges
          @sub_ranges ||= [] unless record.respond_to?(:ranges)
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
          @range_items ||= [] unless record.respond_to?(:items)
          @range_items ||= record.items.map do |range_item|
            # Determine if this item is a range or canvas
            if range_item.respond_to? :id
              canvas_range_item(range_item)
            elsif range_item.respond_to? :label
              range_range_item(range_item)
            end
          end
          @range_items
        end

        def canvas_range_item(range_item)
          { 'type' => 'Canvas', 'id' => build_canvas_id(range_item) }
        end

        def range_range_item(range_item)
          RangeBuilder.new(
            range_item,
            parent,
            canvas_builder_factory: canvas_builder_factory,
            iiif_range_factory: iiif_range_factory
          )
        end

        private

        def build_canvas_id(canvas_item)
          path = "#{parent.manifest_url}/canvas/#{canvas_item.id}"
          if canvas_item.respond_to?(:media_fragment) && canvas_item.media_fragment.present?
            path << "##{canvas_item.media_fragment}"
          end
          path
        end
      end
    end
  end
end
