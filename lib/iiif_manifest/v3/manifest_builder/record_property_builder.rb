module IIIFManifest
  module V3
    class ManifestBuilder
      class RecordPropertyBuilder < ::IIIFManifest::ManifestBuilder::RecordPropertyBuilder
        attr_reader :canvas_builder_factory
        def initialize(record,
                       iiif_search_service_factory:,
                       iiif_autocomplete_service_factory:,
                       canvas_builder_factory:)
          super(record,
                iiif_search_service_factory: iiif_search_service_factory,
                iiif_autocomplete_service_factory: iiif_autocomplete_service_factory)
          @canvas_builder_factory = canvas_builder_factory
        end

        def apply(manifest)
          setup_manifest_from_record(manifest, record)
          # Build the items array
          canvas_builder.apply(manifest.items)
          manifest
        end

        def populate_rendering
          if record.respond_to?(:sequence_rendering)
            record.sequence_rendering.collect do |rendering|
              sequence_rendering = rendering.to_h.except('@id', 'label')
              sequence_rendering['id'] = rendering['@id']
              if rendering['label'].present?
                sequence_rendering['label'] = ManifestBuilder.language_map(rendering['label'])
              end
              sequence_rendering
            end
          else
            []
          end
        end

        private

        def canvas_builder
          canvas_builder_factory.from(record)
        end

          # rubocop:disable Metrics/CyclomaticComplexity
        def setup_manifest_from_record(manifest, record)
          manifest['id'] = record.manifest_url.to_s
          manifest.label = ManifestBuilder.language_map(record.to_s) if record.to_s.present?
          manifest.summary = ManifestBuilder.language_map(record.abstract) if record.present?
          manifest.behavior = viewing_hint if viewing_hint.present?
          manifest.metadata = metadata_from_record(record)
          manifest.viewing_direction = viewing_direction if viewing_direction.present?
          manifest.service = services if search_service.present?
          manifest.rendering = populate_rendering
          manifest.homepage = record.homepage if record.try(:homepage).present?
        end
          # rubocop:enable Metrics/CyclomaticComplexity

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
      end
    end
  end
end
