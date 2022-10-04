# frozen_string_literal: true

module IIIFManifest
  ##
  # Handles configuration for the IIIFManifest gem
  #
  # @see IIIFManifest.config
  class Configuration
    def manifest_value_for(record, property:)
      method_name = map_property_to_method_name(record: record, property: property)
      return nil unless record.respond_to?(method_name)
      record.public_send(method_name)
    end

    def map_property_to_method_name(record:, property:)
      manifest_property_to_record_method_name_map = {
        summary: :description,
        label: :to_s,
        rights: :rights_statement,
        homepage: :homepage
      }
      manifest_property_to_record_method_name_map.fetch(property)
    end
  end
end
