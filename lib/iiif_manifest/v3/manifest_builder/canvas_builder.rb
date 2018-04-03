module IIIFManifest
  module V3
    class ManifestBuilder
      class CanvasBuilder < ::IIIFManifest::ManifestBuilder::CanvasBuilder
        attr_reader :iiif_annotation_page_factory

        def initialize(record, parent, iiif_canvas_factory:, image_builder:, iiif_annotation_page_factory:)
          @record = record
          @parent = parent
          @iiif_canvas_factory = iiif_canvas_factory
          @image_builder = image_builder
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          apply_record_properties
          attach_image if display_image
        end

        def apply(items)
          return items if canvas.items.blank?
          items << canvas
        end

        private

        def apply_record_properties
          canvas['id'] = path
          canvas.label = record.to_s
          annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
          canvas.items = [annotation_page]
        end

        def annotation_page
          @annotation_page ||= iiif_annotation_page_factory.new
        end
      end
    end
  end
end
