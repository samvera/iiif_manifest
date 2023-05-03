module IIIFManifest
  module V3
    class ManifestBuilder
      class PlaceholderCanvasBuilder
        attr_reader :placeholder_content, :canvas_path, :placeholder_canvas_builder_factory, :iiif_annotation_page_factory,
                    :content_builder
        def initialize(placeholder_content,
                       canvas_path,
                       placeholder_canvas_builder_factory:,
                       iiif_annotation_page_factory:,
                       content_builder:)
          @placeholder_content = placeholder_content
          @canvas_path = canvas_path
          @placeholder_canvas_builder_factory = placeholder_canvas_builder_factory
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          @content_builder = content_builder
          apply_record_properties
          attach_content
        end

        def path
          "#{canvas_path}/placeholder"
        end

        def placeholder_canvas
          @placeholder_canvas ||= placeholder_canvas_builder_factory.new
        end

        def apply(canvas)
          canvas.placeholderCanvas = placeholder_canvas
        end

        def apply_record_properties
          placeholder_canvas['id'] = path
          placeholder_canvas['width'] = placeholder_content.width if placeholder_content.width.present?
          placeholder_canvas['height'] = placeholder_content.height if placeholder_content.height.present?
          annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
          placeholder_canvas.items = [annotation_page]
        end

        def attach_content
          content_builder.new(placeholder_content).apply(placeholder_canvas)
        end

        def annotation_page
          @annotation_page ||= iiif_annotation_page_factory.new
        end
      end
    end
  end
end
