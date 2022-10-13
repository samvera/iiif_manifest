# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::ThumbnailBuilder do
  let(:builder) do
    described_class.new(
      display_content,
      iiif_thumbnail_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail,
      image_service_builder_factory: image_service_builder_factory
    )
  end
  let(:url) { 'http://example.com/img1' }
  let(:iiif_endpoint) { double }
  let(:display_content) do
    IIIFManifest::DisplayImage.new(
      url,
      width: 640,
      height: 480,
      iiif_endpoint: iiif_endpoint,
      format: 'Image'
    )
  end
  let(:canvas) { IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas.new }
  let(:image_service_builder_factory) { IIIFManifest::V3::ManifestServiceLocator.image_service_builder_factory }

  before do
    allow(iiif_endpoint).to receive(:url).and_return(url)
    builder.apply(canvas)
  end

  describe '#apply' do
    it 'sets a thumbnail on the canvas' do
      expect(canvas.thumbnail).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail
    end
  end

  describe '#build_thumbnail' do
    it 'sets properties on the thumbnail' do
      expect(canvas.thumbnail['type']).to eq 'Image'
      expect(canvas.thumbnail['id']).to eq url + '/full/!200,200/0/default.jpg'
      expect(canvas.thumbnail['width']).to eq 200
      expect(canvas.thumbnail['height']).to eq 150
    end
  end

  describe '#reduction_ratio' do
    context 'when the content is wider' do
      it 'creates a multiplier based off the max width of 200' do
        allow(display_content).to receive(:width).and_return(2000)
        allow(display_content).to receive(:height).and_return(1000)
        expect(builder.send(:reduction_ratio)).to eq 0.1
      end
    end

    context 'when the content is taller' do
      it 'creates a multiplier based off the max height of 200' do
        allow(display_content).to receive(:width).and_return(1000)
        allow(display_content).to receive(:height).and_return(2000)
        expect(builder.send(:reduction_ratio)).to eq 0.1
      end
    end
  end

  describe '#thumbnail' do
    it 'creates a new thumbnail' do
      expect(builder.send(:thumbnail)).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail
    end
  end
end
