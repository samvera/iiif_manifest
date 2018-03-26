module IIIFManifest::V3
  class ManifestBuilder
    class ImageBuilder < ::IIIFManifest::ManifestBuilder::ImageBuilder
      def apply(canvas)
        annotation['target'] = canvas['id']
        canvas['width'] = annotation.body['width']
        canvas['height'] = annotation.body['height']
        canvas.items += [annotation]
      end
    end
  end
end
