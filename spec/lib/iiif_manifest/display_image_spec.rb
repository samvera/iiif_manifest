require 'spec_helper'

RSpec.describe IIIFManifest::DisplayImage do
  subject { described_class.new(url, width: width, height: height, format: format) }
  let(:url) { "http://bla.org" }
  let(:width) { 10 }
  let(:height) { 10 }
  let(:format) { "image/jpeg" }
  let(:iiif_endpoint) { double("endpoint") }
  it "has accessors" do
    expect(subject.url).to eq url
    expect(subject.width).to eq width
    expect(subject.height).to eq height
  end
  it "has an optional iiif_endpoint argument" do
    r = described_class.new(url, width: width, height: height, iiif_endpoint: iiif_endpoint)
    expect(r.iiif_endpoint).to eq iiif_endpoint
  end
  it "has an optional format" do
    r = described_class.new(url, width: width, height: height, format: format)
    expect(r.format).to eq format
  end
end
