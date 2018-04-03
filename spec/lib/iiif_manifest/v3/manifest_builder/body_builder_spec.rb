require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::BodyBuilder do
  let(:builder) do
    described_class.new(
      display_image,
      iiif_body_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body,
      image_service_builder_factory: image_service_builder_factory
    )
  end
  let(:url) { 'http://example.com/img1' }
  let(:display_image) { IIIFManifest::DisplayImage.new(url, width: 640, height: 480) }
  let(:annotation) { IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation.new }
  let(:image_service_builder_factory) { IIIFManifest::V3::ManifestServiceLocator.image_service_builder_factory }

  describe '#apply' do
    subject { builder.apply(annotation) }

    context 'without iiif_endpoint' do
      it 'sets a resource on the annotation' do
        subject
        expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        expect(annotation.body['id']).to eq url
        expect(annotation.body['type']).to eq 'Image'
        expect(annotation.body).not_to have_key 'service'
      end
    end

    context 'with iiif_endpoint' do
      let(:iiif_endpoint) { IIIFManifest::IIIFEndpoint.new('http://example.com/') }
      let(:display_image) do
        IIIFManifest::DisplayImage.new(url, width: 640, height: 480, iiif_endpoint: iiif_endpoint)
      end

      it 'sets a resource on the annotation' do
        subject
        expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        expect(annotation.body['id']).to eq url
        expect(annotation.body['type']).to eq 'Image'
        expect(annotation.body['service']).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFService
      end
    end
  end
end
