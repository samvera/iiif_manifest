module IIIFManifest
  module V3
    class ManifestBuilder
      class CanvasBuilder
        attr_reader :record, :parent, :iiif_canvas_factory, :content_builder,
                    :choice_builder, :iiif_annotation_page_factory

        def initialize(record,
                       parent,
                       iiif_canvas_factory:,
                       content_builder:,
                       choice_builder:,
                       iiif_annotation_page_factory:)
          @record = record
          @parent = parent
          @iiif_canvas_factory = iiif_canvas_factory
          @content_builder = content_builder
          @choice_builder = choice_builder
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          apply_record_properties
          # Presentation 2.x approach
          attach_image if display_image
          # Presentation 3.0 approach
          attach_content if display_content
        end

        def canvas
          @canvas ||= iiif_canvas_factory.new
        end

        def path
          path = "#{parent.manifest_url}/canvas/#{record.id}"
          path << "##{record.media_fragment}" if record.respond_to?(:media_fragment)
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

          def display_content
            Array.wrap(record.display_content) if record.respond_to?(:display_content)
          end

          def apply_record_properties
            canvas['id'] = path
            canvas.label = ManifestBuilder.language_map(record.to_s) if record.try(:to_s)
            annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
            canvas.items = [annotation_page]
          end

          def annotation_page
            @annotation_page ||= iiif_annotation_page_factory.new
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
      end
    end
  end
end
