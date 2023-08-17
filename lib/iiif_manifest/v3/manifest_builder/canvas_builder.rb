module IIIFManifest
  module V3
    class ManifestBuilder
      class CanvasBuilder
        attr_reader :record, :parent, :iiif_canvas_factory, :content_builder, :choice_builder,
                    :annotation_content_builder, :iiif_annotation_page_factory,
                    :thumbnail_builder_factory, :placeholder_canvas_builder_factory

        def initialize(record,
                       parent,
                       iiif_canvas_factory:,
                       content_builder:,
                       choice_builder:,
                       annotation_content_builder:,
                       iiif_annotation_page_factory:,
                       thumbnail_builder_factory:,
                       placeholder_canvas_builder_factory:)
          @record = record
          @parent = parent
          @iiif_canvas_factory = iiif_canvas_factory
          @content_builder = content_builder
          @choice_builder = choice_builder
          @annotation_content_builder = annotation_content_builder
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          @thumbnail_builder_factory = thumbnail_builder_factory
          @placeholder_canvas_builder_factory = placeholder_canvas_builder_factory
          apply_record_properties
          # Presentation 2.x approach
          attach_image if display_image
          # Presentation 3.0 approach
          attach_content if display_content
          attach_annotation if annotation_content
          attach_placeholder_canvas if placeholder_content
        end

        def canvas
          @canvas ||= iiif_canvas_factory.new
        end

        def path
          path = "#{parent.manifest_url}/canvas/#{record.id}"
          path << "##{record.media_fragment}" if record.respond_to?(:media_fragment) && record.media_fragment.present?
          path
        end

        def apply(items)
          return items if canvas.items.blank?
          items << canvas
        end

        private

        def display_image
          record.display_image if record.respond_to?(:display_image)
        end

        # @return [Array<Object>] if the record has a display content
        # @return [NilClass] if there is no display content
        def display_content
          Array.wrap(record.display_content) if record.respond_to?(:display_content) && record.display_content.present?
        end

        # @return [Array<Object>] if the record has generic annotation content
        # @return [NilClass] if there is no annotation content
        def annotation_content
          return unless record.respond_to?(:annotation_content) && record.annotation_content.present?

          Array.wrap(record.annotation_content)
        end

        def placeholder_content
          record.placeholder_content if record.respond_to?(:placeholder_content)
        end

        # rubocop:disable Metrics/AbcSize
        def apply_record_properties
          canvas['id'] = path
          canvas.label = ManifestBuilder.language_map(record.to_s) if record.to_s.present?
          annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
          canvas.items = [annotation_page]
          apply_annotation_content_to(canvas)
          apply_thumbnail_to(canvas)
          canvas.rendering = populate(:rendering) if populate(:rendering).present?
          canvas.see_also = populate(:see_also) if populate(:see_also).present?
          canvas.part_of = populate(:part_of) if populate(:part_of).present?
          canvas.metadata = metadata_from_record(record) if metadata_from_record(record).present?
        end
        # rubocop:enable Metrics/AbcSize

        def apply_annotation_content_to(canvas)
          return if annotation_content.blank?

          generic_annotation_page['id'] = "#{path}/annotation_page/#{generic_annotation_page.index}"
          canvas.annotations = [generic_annotation_page]
        end

        def apply_thumbnail_to(canvas)
          if display_image
            canvas.thumbnail = Array(thumbnail_builder_factory.new(display_image).build)
          elsif display_content.try(:first)
            canvas.thumbnail = Array(thumbnail_builder_factory.new(display_content.first).build)
          end
        end

        def annotation_page
          @annotation_page ||= iiif_annotation_page_factory.new
        end

        def generic_annotation_page
          @generic_annotation_page ||= iiif_annotation_page_factory.new
        end

        def attach_image
          content_builder.new(display_image).apply(canvas)
        end

        def attach_content
          if display_content.size == 1
            content_builder.new(display_content.first).apply(canvas)
          else
            choice_builder.new(display_content).apply(canvas)
          end
        end

        def attach_annotation
          annotation_content.each do |an|
            annotation = annotation_content_builder.new(an).apply(canvas)
            generic_annotation_page.items += [annotation]
          end
        end

        def attach_placeholder_canvas
          canvas.placeholder_canvas = placeholder_canvas_builder_factory.new(placeholder_content, path).build
        end

        def populate(property)
          property = :sequence_rendering if property == :rendering

          return unless record.respond_to?(property)
          record.send(property).collect do |prop|
            output = prop.to_h.except('@id', 'label')
            output['id'] = prop['@id']
            output['label'] = ManifestBuilder.language_map(prop['label']) if prop['label'].present?
            output
          end
        end

        def metadata_from_record(record)
          return unless valid_v3_metadata?
          record.item_metadata
        end

        # Validate item_metadata against the IIIF spec format for metadata
        #
        # @return [Boolean]
        def valid_v3_metadata?
          return false unless record.respond_to?(:item_metadata)
          metadata = record.item_metadata
          valid_v3_metadata_fields?(metadata)
        end

        # Item metadata must be an array containing hashes
        #
        # @param metadata [Array<Hash>] a list of metadata with label and value as required keys for each entry
        # @return [Boolean]
        def valid_v3_metadata_fields?(metadata)
          metadata.is_a?(Array) && metadata.all? do |metadata_field|
            metadata_field.is_a?(Hash) &&
              ManifestBuilder.valid_language_map?(metadata_field['label']) &&
              ManifestBuilder.valid_language_map?(metadata_field['value'])
          end
        end
      end
    end
  end
end
