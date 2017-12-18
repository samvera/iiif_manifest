require 'spec_helper'

RSpec.describe IIIFManifest::IIIFSearchEndpoint do
  let(:endpoint) { described_class.new(url) }

  let(:url) { 'http://bla.org' }

  context 'with default values' do
    it 'has accessors' do
      expect(endpoint.url).to eq url
      expect(endpoint.label).to eq 'Search within this manifest'
    end
    it 'can return context' do
      expect(endpoint.context).to eq 'http://iiif.io/api/search/0/context.json'
    end
    it 'can return profile' do
      expect(endpoint.profile).to eq 'http://iiif.io/api/search/0/search'
    end
  end

  context 'with user supplied valued' do
    let(:endpoint) { described_class.new(url, label: 'Search this manifest', version: '1') }

    let(:url) { 'http://bla.org' }

    it 'has accessors' do
      expect(endpoint.url).to eq url
      expect(endpoint.label).to eq 'Search this manifest'
    end
    it 'can return context' do
      expect(endpoint.context).to eq 'http://iiif.io/api/search/1/context.json'
    end
    it 'can return profile' do
      expect(endpoint.profile).to eq 'http://iiif.io/api/search/1/search'
    end
  end
end
