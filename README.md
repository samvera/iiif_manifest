# IIIFManifest
[![CircleCI](https://circleci.com/gh/samvera/iiif_manifest.svg?style=svg)](https://circleci.com/gh/samvera/iiif_manifest)
[![Coverage Status](https://coveralls.io/repos/github/samvera/iiif_manifest/badge.svg)](https://coveralls.io/github/samvera/iiif_manifest)

IIIF http://iiif.io/ defines an API for presenting related images in a viewer. This transforms Hydra::Works objects into that format usable by players such as http://universalviewer.io/

## Usage

Your application ***must*** have an object that implements `#file_set_presenters` and `#work_presenters`.  The former method should return as set of leaf nodes and the later any interstitial nodes. If none are found an empty array should be returned.

Additionally, it ***must*** have a `#description` method that returns a string.

Additionally it ***should*** implement `#manifest_url` that shows where the manifest can be found.

Additionally it ***should*** implement `#manifest_metadata` to provide an array containing hashes of metadata Label/Value pairs.

Additionally it ***may*** implement `#search_service` to contain the url for a IIIF search api compliant search endpoint and `#autocomplete_service` to contain the url for a IIIF search api compliant autocomplete endpoint. Please note, the autocomplete service is embedded within the search service description so if an autocomplete_service is supplied without a search_service it will be ignored. The IIIF `profile` added to the service descriptions is version 0 as this is the version supported by the current version of Universal Viewer. Only include a search_service within the manifest if your application has implemented a IIIF search service at the endpoint specified in the manifest.

Additionally it ***may*** implement `#sequence_rendering` to contain an array of hashes for file downloads to be offered at sequences level. Each hash must contain "@id", "format" (mime type) and "label" (eg. `{ "@id" => "download url", "format" => "application/pdf", "label" => "user friendly label" }`).

Finally, it ***may*** implement `ranges`, which returns an array of objects which
represent a table of contents or similar structure, each of which responds to
`label`, `ranges`, and `file_set_presenters`.

For example:

 ```ruby
  class Book
    def initialize(id, pages = [])
      @id = id
      @pages = pages
    end

    def file_set_presenters
      @pages
    end

    def work_presenters
      []
    end

    def manifest_url
      "http://test.host/books/#{@id}/manifest"
    end

    def description
      'a brief description'
    end

    def manifest_metadata
          [
            { "label" => "Title", "value" => "Title of the Item" },
            { "label" => "Creator", "value" => "Morrissey, Stephen Patrick" }
          ]
    end

    def search_service
      "http://test.host/books/#{@id}/search"
    end

    def autocomplete_service
      "http://test.host/books/#{@id}/autocomplete"
    end

    def sequence_rendering
      [{"@id" => "http://test.host/file_set/id/download", "format" => "application/pdf", "label" => "Download"}]
    end

    def ranges
      [
        ManifestRange.new(
          label: "Table of Contents",
          ranges: [
            ManifestRange.new(
              label: "Chapter 1",
              file_set_presenters: @pages
            )
          ]
        )
      ]
    end
  end

  class ManifestRange
    attr_reader :label, :ranges, :file_set_presenters
    def initialize(label:, ranges: [], file_set_presenters: [])
      @label = label
      @ranges = ranges
      @file_set_presenters = file_set_presenters
    end
  end
```

The class that represents the leaf nodes, must implement `#id`. It must also implement `#display_image` which returns an instance of `IIIFManifest::DisplayImage`

```ruby
  class Page
    def initialize(id)
      @id = id
    end

    def id
      @id
    end

    def display_image
      IIIFManifest::DisplayImage.new(id,
                                     width: 100,
                                     height: 100,
                                     format: "image/jpeg",
                                     iiif_endpoint: endpoint
                                     )
    end

    private

      def endpoint
        IIIFManifest::IIIFEndpoint.new("http://test.host/images/#{id}",
                                       profile: "http://iiif.io/api/image/2/level2.json")
      end
  end
```

Then you can produce the manifest on the book object like this:

```ruby
  book = Book.new('book-77',[Page.new('page-99')])
  IIIFManifest::ManifestFactory.new(book).to_h.to_json
```

## Presentation 3.0 (Alpha)

Provisional support for the [3.0 alpha version of the IIIF presentation api spec](https://iiif.io/api/presentation/3.0/) has been added with a focus on audiovisual content.  The [change log](https://iiif.io/api/presentation/3.0/change-log/) lists the changes to the specification.

The presentation 3.0 support has been contained to the `V3` namespace.  Version 2.0 manifests are still be built using `IIIFManifest::ManifestFactory` while version 3.0 manifests can now be built using `IIIFManifest::V3::ManifestFactory`.

```ruby
  book = Book.new('book-77',[Page.new('page-99')])
  IIIFManifest::V3::ManifestFactory.new(book).to_h.to_json
```

### Notable changes for Presentation 3.0
- Presenters must still define `#description` but it is now serialized as `summary`. (https://iiif.io/api/presentation/3.0/change-log/#126-rename-description-to-summary)
- All textual strings, including metadata labels and values, are now serialized as language maps and may be provided as a hash with language code keys with string values.  Values not provided in this format are automatically converted so no change to `#description`, `#manifest_metadata`, range labels, or other fields are required. (https://iiif.io/api/presentation/3.0/change-log/#133-use-language-map-pattern-for-label-value-summary)
- Presenters ***may*** implement `#homepage` to contain a hash for linking back to a repository webpage for this manifest. The hash must contain "id", "format" (mime type), "type", and "label" (eg. `{ "id" => "repository url", "format" => "text/html", "type" => "Text", "label" => { "en": ["View in repository"] }`).
- File set presenters may target a fragment of its content by providing `#media_fragment` which will be appended to its `id`.
- Range objects may now implement `#items` instead of `#ranges` and `#file_set_presenters` to allow for interleaving these objects.  `#items` is not required and existing range objects should continue to work.
- File set presenters may provide `#display_content` which should return an instance of `IIIFManifest::V3::DisplayContent` (or an array of instances in the case of a user `Choice`).  `#display_image` is no longer required but will still work if provided.
- DisplayContent may provide `#auth_service` which should return a hash containing a IIIF Authentication service definition (https://iiif.io/api/auth/1.0/) that will be included on the content resource.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samvera-labs/iiif_manifest. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
