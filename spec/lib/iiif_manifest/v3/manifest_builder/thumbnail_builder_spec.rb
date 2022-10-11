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
  let(:url) { 'http://example.com/img1/full/600,/0/default.jpg' }
  let(:display_content) { IIIFManifest::DisplayImage.new(url, width: 640, height: 480) }
  let(:canvas) { IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas.new }
  let(:image_service_builder_factory) { IIIFManifest::V3::ManifestServiceLocator.image_service_builder_factory }

  describe '#apply' do
    subject(:thumbnail_builder) { builder.apply(canvas) }

    context 'without iiif_endpoint' do
      it 'sets a thumbnail on the canvas' do
        thumbnail_builder
        expect(canvas.thumbnail).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail
      end
    end
  end
end
