module IIIFManifest
  module V3
    class ManifestBuilder
      class ResourceBuilder < ::IIIFManifest::ManifestBuilder::ResourceBuilder
        def apply(annotation)
          resource['id'] = display_image.url
          resource['type'] = 'Image'
          resource['height'] = display_image.height
          resource['width'] = display_image.width
          resource['format'] = display_image.format if display_image.format
          image_service_builder.apply(resource) if iiif_endpoint
          annotation.body = resource
        end
      end
    end
  end
end
