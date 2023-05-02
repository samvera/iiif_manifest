module IIIFManifest
  module V3
    class ManifestBuilder
      class PlaceholderCanvasBuilder
        attr_reader :display_image, :iiif_canvas_factory, :iiif_annotation_page_factory,
                    :content_builder
        def initialize(display_image,
                       iiif_canvas_factory:,
                       iiif_annotation_page_factory:,
                       content_builder:)
          @display_image = display_image
          @iiif_canvas_factory = iiif_canvas_factory
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          @content_builder = content_builder
          apply_record_properties
          attach_content if display_image
        end

        def placeholder_canvas
          @placeholder_canvas ||= iiif_canvas_factory.new
        end

        def path
          "#{parent.manifest_url}/canvas/#{record.id}/placeholder"
        end

        def apply(canvas)
          # Assume first item in canvas is an annotation page
          # annotation['id'] = "#{canvas.items.first['id']}/annotation/#{annotation.index}"
          # annotation['target'] = canvas['id']
          placeholder_canvas['width'] = display_image.width if display_image.width.present?
          placeholder_canvas['height'] = display_image.height if display_image.height.present?
          canvas.placeholderCanvas = placeholderCanvas
        end

        def apply_record_properties
          placeholder_canvas['id'] = path
          annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
          placeholder_canvas.items = [annotation_page]
        end

        def annotation_page
          @annotation_page ||= iiif_annotation_page_factory.new
        end
      end
    end
  end
end
