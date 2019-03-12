require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::CanvasBuilder do
  let(:builder) do
    described_class.new(
      record,
      parent,
      iiif_canvas_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas,
      content_builder: IIIFManifest::V3::ManifestBuilder::ContentBuilder,
      choice_builder: IIIFManifest::V3::ManifestBuilder::ChoiceBuilder,
      iiif_annotation_page_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage
    )
  end
  let(:record) { double(id: 'test-22') }
  let(:parent) { double(manifest_url: 'http://test.host/books/book-77/manifest') }

  describe '#new' do
    it 'builds a canvas with a label' do
      allow(record).to receive(:to_s).and_return('Test Canvas')
      expect(builder.canvas.label).to eq('@none' => ['Test Canvas'])
    end
  end

  describe '#path' do
    it 'returns a canvas url' do
      expect(builder.path).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
    end

    context 'when media_fragment is defined' do
      before do
        allow(record).to receive(:media_fragment).and_return('xywh=160,120,320,240')
      end
      it 'returns a canvas url' do
        expect(builder.path).to eq 'http://test.host/books/book-77/manifest/canvas/test-22#xywh=160,120,320,240'
      end

      context 'and is blank' do
        before do
          allow(record).to receive(:media_fragment).and_return(nil)
        end
        it 'returns a canvas url' do
          expect(builder.path).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
        end
      end
    end
  end
end
