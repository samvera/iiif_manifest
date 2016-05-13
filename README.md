# IIIFManifest

IIIF http://iiif.io/ defines an API for presenting related images in a viewer. This transforms Hydra::Works objects into that format usable by players such as http://universalviewer.io/

## Usage

You application must have an object that implements `#file_set_presenters` and `#work_presenters`.  The former method should return as set of leaf nodes and the later any interstitial nodes. If none are found an empty array should be returned. Additionally it should implement `#manifest_url` that shows where the manifest can be found. Finally, it must have a `#description` method that returns a string.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/projecthydra-labs/iiif\_manifest. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

