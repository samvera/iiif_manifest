require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::BodyBuilder do
  let(:builder) do
    described_class.new(
      display_content,
      iiif_body_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body,
      image_service_builder_factory: image_service_builder_factory
    )
  end
  let(:url) { 'http://example.com/img1' }
  let(:display_content) { IIIFManifest::DisplayImage.new(url, width: 640, height: 480) }
  let(:annotation) { IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation.new }
  let(:image_service_builder_factory) { IIIFManifest::V3::ManifestServiceLocator.image_service_builder_factory }

  describe '#apply' do
    subject { builder.apply(annotation) }

    context 'without iiif_endpoint' do
      it 'sets a body on the annotation' do
        subject
        expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        expect(annotation.body['id']).to eq url
        expect(annotation.body['type']).to eq 'Image'
        expect(annotation.body).not_to have_key 'service'
      end
    end

    context 'with iiif_endpoint' do
      let(:iiif_endpoint) { IIIFManifest::IIIFEndpoint.new('http://example.com/') }
      let(:display_content) do
        IIIFManifest::DisplayImage.new(url, width: 640, height: 480, iiif_endpoint: iiif_endpoint)
      end

      it 'sets a body on the annotation' do
        subject
        expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        expect(annotation.body['id']).to eq url
        expect(annotation.body['type']).to eq 'Image'
        expect(annotation.body['service']).to be_kind_of Array
        service = annotation.body['service'].first
        expect(service).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFService
        expect(service['id']).to eq iiif_endpoint.url
        expect(service['profile']).to eq iiif_endpoint.profile
        expect(service['type']).to eq 'ImageService2'
      end
    end

    context 'with display image' do
      it 'sets a body on the annotation' do
        subject
        expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        expect(annotation.body['id']).to eq url
        expect(annotation.body['type']).to eq 'Image'
        expect(annotation.body['width']).to eq 640
        expect(annotation.body['height']).to eq 480
        expect(annotation.body['format']).to be_nil
        expect(annotation.body['duration']).to be_nil
        expect(annotation.body['label']).to be_nil
      end
    end

    context 'with display content' do
      context 'with image content' do
        let(:display_content) do
          IIIFManifest::V3::DisplayContent.new(url, width: 640,
                                                    height: 480,
                                                    type: 'Image',
                                                    format: 'image/jpeg',
                                                    label: 'full')
        end

        it 'sets a body on the annotation' do
          subject
          expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
          expect(annotation.body['id']).to eq url
          expect(annotation.body['type']).to eq 'Image'
          expect(annotation.body['width']).to eq 640
          expect(annotation.body['height']).to eq 480
          expect(annotation.body['format']).to eq 'image/jpeg'
          expect(annotation.body['duration']).to be_nil
          expect(annotation.body['label']).to eq 'full'
        end
      end

      context 'with audio content' do
        let(:display_content) do
          IIIFManifest::V3::DisplayContent.new(url, duration: 1000,
                                                    type: 'Audio',
                                                    format: 'audio/aac',
                                                    label: 'Track 1')
        end

        it 'sets a body on the annotation' do
          subject
          expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
          expect(annotation.body['id']).to eq url
          expect(annotation.body['type']).to eq 'Audio'
          expect(annotation.body['duration']).to eq 1000
          expect(annotation.body['format']).to eq 'audio/aac'
          expect(annotation.body['label']).to eq 'Track 1'
          expect(annotation.body['width']).to be_nil
          expect(annotation.body['height']).to be_nil
        end
      end

      context 'with video content' do
        let(:display_content) do
          IIIFManifest::V3::DisplayContent.new(url, width: 640,
                                                    height: 480,
                                                    duration: 1000,
                                                    type: 'Video',
                                                    format: 'video/mp4',
                                                    label: 'Reel 1')
        end

        it 'sets a body on the annotation' do
          subject
          expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
          expect(annotation.body['id']).to eq url
          expect(annotation.body['type']).to eq 'Video'
          expect(annotation.body['width']).to eq 640
          expect(annotation.body['height']).to eq 480
          expect(annotation.body['duration']).to eq 1000
          expect(annotation.body['label']).to eq 'Reel 1'
          expect(annotation.body['format']).to eq 'video/mp4'
        end
      end
    end
  end
end
