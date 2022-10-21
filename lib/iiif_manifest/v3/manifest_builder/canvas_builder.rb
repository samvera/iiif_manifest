module IIIFManifest
  module V3
    class ManifestBuilder
      class CanvasBuilder
        attr_reader :record, :parent, :manifest, :iiif_canvas_factory, :content_builder,
                    :choice_builder, :iiif_annotation_page_factory, :thumbnail_builder_factory

        def initialize(record,
                       parent,
                       manifest,
                       iiif_canvas_factory:,
                       content_builder:,
                       choice_builder:,
                       iiif_annotation_page_factory:,
                       thumbnail_builder_factory:)
          @record = record
          @parent = parent
          @manifest = manifest
          @iiif_canvas_factory = iiif_canvas_factory
          @content_builder = content_builder
          @choice_builder = choice_builder
          @iiif_annotation_page_factory = iiif_annotation_page_factory
          @thumbnail_builder_factory = thumbnail_builder_factory
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

        # @return [Array<Object>] if the record has a display content
        # @return [NilClass] if there is no display content
        def display_content
          Array.wrap(record.display_content) if record.respond_to?(:display_content) && record.display_content.present?
        end

        def manifest_can_have_thumbnail
          manifest.respond_to?(:thumbnail)
        end

        def apply_record_properties
          canvas['id'] = path
          canvas.label = ManifestBuilder.language_map(record.to_s) if record.to_s.present?
          annotation_page['id'] = "#{path}/annotation_page/#{annotation_page.index}"
          canvas.items = [annotation_page]
          apply_thumbnail_to(manifest, canvas)
        end

        def apply_thumbnail_to(manifest, canvas)
          return unless iiif_endpoint

          if display_image
            apply_manifest_thumbnail(manifest, display_image)
            canvas.thumbnail = Array(thumbnail_builder_factory.new(display_image).build)
          elsif display_content.try(:first)
            apply_manifest_thumbnail(manifest, display_content.first)
            canvas.thumbnail = Array(thumbnail_builder_factory.new(display_content.first).build)
          end
        end

        def collection?
          manifest.is_a? IIIFManifest::Collection
        end

        def apply_manifest_thumbnail(manifest, display_type)
          return unless manifest_can_have_thumbnail

          if collection?
            # if manifest.thumbnail is nil, make it an Array, then add more thumbnails into it
            (manifest.thumbnail ||= []) << Array(thumbnail_builder_factory.new(display_type).build)
          else
            manifest.thumbnail ||= Array(thumbnail_builder_factory.new(display_type).build)
          end
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

        def iiif_endpoint
          display_image.try(:iiif_endpoint) || Array(display_content).first.try(:iiif_endpoint)
        end
      end
    end
  end
end
