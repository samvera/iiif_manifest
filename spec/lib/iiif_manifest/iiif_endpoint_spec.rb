require 'spec_helper'

RSpec.describe IIIFManifest::IIIFEndpoint do
  subject { described_class.new(url, profile: profile) }
  let(:url) { "http://bla.org" }
  let(:profile) { "myprofile.net" }
  it "has accessors" do
    expect(subject.url).to eq url
    expect(subject.profile).to eq profile
  end
  it "can return context" do
    expect(subject.context).to eq "http://iiif.io/api/image/2/context.json"
  end
end
