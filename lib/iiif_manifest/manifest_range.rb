module IIIFManifest
  class ManifestRange
    attr_reader :label, :ranges, :file_set_presenters

    def initialize(label:, ranges: [], file_set_presenters: [])
      @label = label
      @ranges = ranges
      @file_set_presenters = file_set_presenters
    end
  end
end
