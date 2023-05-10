# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::PlaceholderCanvasBuilder do
  subject(:placeholder_canvas_builder) { builder.build }
  let(:builder) do
    described_class.new(
      placeholder_content,
      canvas_path,
      iiif_placeholder_canvas_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas,
      iiif_annotation_page_factory: iiif_annotation_page_factory,
      content_builder: content_builder
    )
  end
  let(:canvas_path) { 'http://example.com/canvas' }
  let(:placeholder_content) do
    IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, type: 'Image',
                                                            width: 100,
                                                            height: 100,
                                                            duration: 100,
                                                            format: 'image/jpeg')
  end
  let(:iiif_annotation_page_factory) { IIIFManifest::V3::ManifestServiceLocator.iiif_annotation_page_factory }
  let(:content_builder) { IIIFManifest::V3::ManifestServiceLocator.content_builder }
  let(:placeholder_canvas) { placeholder_canvas_builder }

  before do
    placeholder_canvas_builder
  end

  describe "#build" do
    context 'when placeholder_content is nil' do
      let(:placeholder_content) { nil }

      it 'return nil' do
        expect(placeholder_canvas).to be_nil
      end
    end

    context 'when placeholder_content is not nil' do
      it 'return a canvas' do
        expect(placeholder_canvas).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
      end
    end
  end

  describe "#build_placeholder_canvas" do
    it 'sets properties on the canvas' do
      expect(placeholder_canvas['id']).to eq "http://example.com/canvas/placeholder"
      expect(placeholder_canvas['type']).to eq "Canvas"
      expect(placeholder_canvas['width']).to eq 100
      expect(placeholder_canvas['height']).to eq 100
      expect(placeholder_canvas['duration']).to eq 100
      expect(placeholder_canvas['items']).to be_an Array

      item = placeholder_canvas['items'].first
      expect(item['type']).to eq "AnnotationPage"
      expect(item['id']).to include "http://example.com/canvas/placeholder/annotation_page/"
      expect(item['items']).to be_an Array

      annotation = item['items'].first
      expect(annotation['type']).to eq "Annotation"
      expect(annotation['motivation']).to eq "painting"
      expect(annotation.key?('body')).to eq true
      expect(annotation['target']).to eq "http://example.com/canvas/placeholder"

      expect(annotation['body']['type']).to eq "Image"
      expect(annotation['body']['duration']).to eq 100
      expect(annotation['body']['format']).to eq "image/jpeg"
    end
  end
end
