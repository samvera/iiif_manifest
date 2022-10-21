module IIIFManifest
  module V3
    class ManifestBuilder
      class RecordPropertyBuilder < ::IIIFManifest::ManifestBuilder::RecordPropertyBuilder
        attr_reader :canvas_builder_factory, :thumbnail_builder_factory
        def initialize(record,
                       iiif_search_service_factory:,
                       iiif_autocomplete_service_factory:,
                       canvas_builder_factory:,
                       thumbnail_builder_factory:)
          super(record,
                iiif_search_service_factory: iiif_search_service_factory,
                iiif_autocomplete_service_factory: iiif_autocomplete_service_factory)
          @canvas_builder_factory = canvas_builder_factory
          @thumbnail_builder_factory = thumbnail_builder_factory
        end

        def apply(manifest)
          setup_manifest_from_record(manifest, record)
          # Build the items array
          canvas_builder.apply(manifest.items)
          manifest
        end

        def populate_rendering
          return unless record.respond_to?(:sequence_rendering)
          record.sequence_rendering.collect do |rendering|
            sequence_rendering = rendering.to_h.except('@id', 'label')
            sequence_rendering['id'] = rendering['@id']
            if rendering['label'].present?
              sequence_rendering['label'] = ManifestBuilder.language_map(rendering['label'])
            end
            sequence_rendering
          end
        end

        private

        def canvas_builder
          canvas_builder_factory.from(record)
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
        def setup_manifest_from_record(manifest, record)
          manifest['id'] = record.manifest_url.to_s
          label = ::IIIFManifest.config.manifest_value_for(record, property: :label)
          manifest.label = ManifestBuilder.language_map(label) if label.present?
          summary = ::IIIFManifest.config.manifest_value_for(record, property: :summary)
          manifest.summary = ManifestBuilder.language_map(summary) if summary.present?
          rights = ::IIIFManifest.config.manifest_value_for(record, property: :rights)
          manifest.rights = rights if rights.present?
          manifest.behavior = viewing_hint if viewing_hint.present?
          manifest.metadata = metadata_from_record(record) if metadata_from_record(record).present?
          manifest.viewing_direction = viewing_direction if viewing_direction.present?
          manifest.service = services if search_service.present?
          manifest.rendering = populate_rendering if populate_rendering.present?
          homepage = ::IIIFManifest.config.manifest_value_for(record, property: :homepage)
          manifest.homepage = homepage if homepage.present?
          apply_thumbnail_to(manifest)
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength

        def metadata_from_record(record)
          if valid_v3_metadata?
            record.manifest_metadata
          elsif valid_metadata?
            transform_metadata(record.manifest_metadata)
          end
        end

          # Validate manifest_metadata against the IIIF spec format for metadata
          #
          # @return [Boolean]
        def valid_v3_metadata?
          return false unless record.respond_to?(:manifest_metadata)
          metadata = record.manifest_metadata
          valid_v3_metadata_fields?(metadata)
        end

          # Manifest metadata must be an array containing hashes
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

        def transform_metadata(metadata)
          metadata.collect { |field| transform_field(field) }
        end

        def transform_field(field)
          metadata_field = {}
          metadata_field['label'] = ManifestBuilder.language_map(field['label'])
          metadata_field['value'] = ManifestBuilder.language_map(field['value'])
          metadata_field
        end

        def apply_thumbnail_to(manifest)
          return unless iiif_endpoint

          if display_image
            manifest.thumbnail = Array(thumbnail_builder_factory.new(display_image).build)
          elsif display_content
            manifest.thumbnail = Array(thumbnail_builder_factory.new(display_content).build)
          end
        end

        def display_image
          return @display_image if defined?(@display_image)
          @display_image = record.try(:member_presenters)&.first&.display_image
        end

        def display_content
          return @display_content if defined?(@display_content)
          @display_content = record.try(:member_presenters)&.first&.display_content
        end

        def iiif_endpoint
          display_image.try(:iiif_endpoint) || Array(display_content).first.try(:iiif_endpoint)
        end
      end
    end
  end
end
