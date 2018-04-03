module IIIFManifest
  module V3
    class ManifestBuilder
      class ImageBuilder < ::IIIFManifest::ManifestBuilder::ImageBuilder
        def apply(canvas)
          annotation['target'] = canvas['id']
          canvas['width'] = annotation.body['width']
          canvas['height'] = annotation.body['height']
          # Assume first item in canvas is an annotation page
          canvas.items.first.items += [annotation]
        end
      end
    end
  end
end
