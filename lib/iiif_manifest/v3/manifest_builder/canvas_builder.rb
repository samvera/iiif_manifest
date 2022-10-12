module IIIFManifest
  module V3
    class ManifestBuilder
      class CanvasBuilder
        attr_reader :record, :parent, :iiif_canvas_factory, :content_builder,
                    :choice_builder, :iiif_annotation_page_factory, :iiif_thumbnail_factory

        def initialize(record,
                       parent,
                       iiif_canvas_factory:,
                       content_builder:,
                       choice_builder:,
                       iiif_annotation_page_factory:,
                       iiif_thumbnail_factory:)
          @record = record
          @parent = parent
          @iiif_canvas_factory = iiif_canvas_factory
          @content_builder = content_builder
          @choice_builder = choice_builder
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          @iiif_thumbnail_factory = iiif_thumbnail_factory
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

        def display_content
          Array.wrap(record.display_content) if record.respond_to?(:display_content) && record.display_content.present?
        end

        def apply_record_properties
          canvas['id'] = path
          canvas.label = ManifestBuilder.language_map(record.to_s) if record.to_s.present?
          annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
          canvas.items = [annotation_page]
          canvas.thumbnail = [build_thumbnail(record.display_content)] if display_content
        end

        def build_thumbnail(image)
          thumbnail['id'] = File.join(image.iiif_endpoint.url, "full", "!200,200", "0", "default.jpg")
          thumbnail['height'] = (image.height * reduction_ratio).round
          thumbnail['width'] = (image.width * reduction_ratio).round
          thumbnail['format'] = image.format
          thumbnail
        end

        def reduction_ratio
          width = record.display_content.width
          height = record.display_content.height
          max_edge = 200.0
          return 1 if width <= max_edge && height <= max_edge

          long_edge = [height, width].max
          max_edge / long_edge
        end

        def thumbnail
          @thumbnail ||= iiif_thumbnail_factory.new
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
