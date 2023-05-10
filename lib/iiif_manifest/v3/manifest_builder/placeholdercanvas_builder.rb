module IIIFManifest
  module V3
    class ManifestBuilder
      class PlaceholderCanvasBuilder
        attr_reader :placeholder_content, :canvas_path, :iiif_placeholder_canvas_factory, :iiif_annotation_page_factory,
                    :content_builder
        def initialize(placeholder_content,
                       canvas_path,
                       iiif_placeholder_canvas_factory:,
                       iiif_annotation_page_factory:,
                       content_builder:)
          @placeholder_content = placeholder_content
          @canvas_path = canvas_path
          @iiif_placeholder_canvas_factory = iiif_placeholder_canvas_factory
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          @content_builder = content_builder
        end

        def build
          return nil if placeholder_content.nil?

          build_placeholder_canvas
          attach_content

          placeholder_canvas
        end

        private

        def path
          "#{canvas_path}/placeholder"
        end

        def placeholder_canvas
          @placeholder_canvas ||= iiif_placeholder_canvas_factory.new
        end

        def build_placeholder_canvas
          placeholder_canvas['id'] = path
          placeholder_canvas['width'] = placeholder_content.width if placeholder_content.width.present?
          placeholder_canvas['height'] = placeholder_content.height if placeholder_content.height.present?
          placeholder_canvas['duration'] = placeholder_content.duration if placeholder_content.duration.present?
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
