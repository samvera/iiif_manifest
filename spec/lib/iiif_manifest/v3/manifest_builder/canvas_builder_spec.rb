# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::CanvasBuilder do
  let(:content_builder) do
    IIIFManifest::V3::ManifestBuilder::ContentBuilder
  end
  let(:builder) do
    described_class.new(
      record,
      parent,
      iiif_canvas_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas,
      content_builder: content_builder,
      choice_builder: IIIFManifest::V3::ManifestBuilder::ChoiceBuilder,
      iiif_annotation_page_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage,
      thumbnail_builder_factory: thumbnail_builder_factory
    )
  end

  let(:parent) { double(manifest_url: 'http://test.host/books/book-77/manifest') }

  after do
    Object.send(:remove_const, :MyWork)
  end

  let(:url) { 'http://example.com/img1.jpg' }
  let(:iiif_endpoint) { double('endpoint', url: 'http://example.com/img1') }
  let(:display_content) do
    IIIFManifest::V3::DisplayContent.new(url,
                                         width: 640,
                                         height: 480,
                                         type: 'Image',
                                         format: 'image/jpeg',
                                         label: 'full',
                                         iiif_endpoint: iiif_endpoint)
  end
  let(:record) do
    MyWork.new(display_content: display_content)
  end

  before do
    class MyWork
      attr_reader :display_content

      def initialize(display_content:)
        @display_content = display_content
      end

      def id
        'test-22'
      end
    end

    allow(body_builder).to receive(:apply).and_return(iiif_body)
    allow(body_builder_factory).to receive(:new).and_return(body_builder)
    allow(iiif_annotation_factory).to receive(:new).and_return(iiif_annotation)
    allow(content_builder).to receive(:new).and_return(built_content)
    allow(thumbnail_builder).to receive(:build).and_return(iiif_thumbnail)
    allow(thumbnail_builder_factory).to receive(:new).and_return(thumbnail_builder)
  end

  let(:iiif_body) do
    body = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body.new
    body['width'] = '100px'
    body['height'] = '100px'
    body['duration'] = nil
    body
  end

  let(:iiif_thumbnail) do
    thumbnail = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail.new
    thumbnail['width'] = 200
    thumbnail['height'] = 150
    thumbnail['duration'] = nil
    thumbnail
  end

  let(:iiif_annotation) do
    annotation = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation.new
    annotation.body = iiif_body
    annotation
  end

  let(:iiif_annotation_factory) do
    double('IIIF Annotation Factory')
  end

  let(:body_builder) do
    instance_double(IIIFManifest::V3::ManifestBuilder::BodyBuilder)
  end

  let(:body_builder_factory) do
    double('Body Builder')
  end

  let(:thumbnail_builder) do
    instance_double(IIIFManifest::V3::ManifestBuilder::ThumbnailBuilder)
  end

  let(:thumbnail_builder_factory) do
    double('Thumbnail Builder')
  end

  let(:built_content) do
    IIIFManifest::V3::ManifestBuilder::ContentBuilder.new(
      record.display_content,
      iiif_annotation_factory: iiif_annotation_factory,
      body_builder_factory: body_builder_factory
    )
  end

  let(:content_builder) do
    double('Content Builder')
  end

  describe '#canvas' do
    context 'when the display content is populated for a record' do
      it 'generates the canvas' do
        canvas = builder.canvas
        expect(canvas).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
        values = canvas.inner_hash

        expect(values).to include "type" => "Canvas"
        expect(values).to include "id" => "http://test.host/books/book-77/manifest/canvas/test-22"
        expect(values).to include "items"

        expect(values).to include "thumbnail"
        thumbnail = values['thumbnail'].first
        expect(thumbnail).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail
        thumbnail_values = thumbnail.inner_hash
        expect(thumbnail_values).to include "type" => "Image"
        expect(thumbnail_values).to include "width" => 200
        expect(thumbnail_values).to include "height" => 150

        items = values['items']
        expect(items.length).to eq 1
        page = items.first
        expect(page).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage
        items = page.items
        expect(items.length).to eq 1
        annotation = items.first
        expect(annotation).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation
        values = annotation.inner_hash
        expect(values).to include('body')
        body = values['body']
        expect(body).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        values = body.inner_hash
        expect(values).to include "width" => "100px"
        expect(values).to include "height" => "100px"
        expect(values).to include "duration" => nil
      end
    end

    context 'when the display content is empty for an item' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def display_content
            []
          end
        end
      end

      it 'generates the canvas' do
        canvas = builder.canvas
        expect(canvas).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
        values = canvas.inner_hash

        expect(values).to include "type" => "Canvas"
        expect(values).to include "id" => "http://test.host/books/book-77/manifest/canvas/test-22"

        expect(values).to include 'items'
        items = values['items']
        expect(items.length).to eq 1
        page = items.first
        expect(page).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage
        expect(page.items).to be_empty
      end
    end
  end

  describe '#new' do
    it 'builds a canvas with a label' do
      allow(record).to receive(:to_s).and_return('Test Canvas')
      expect(builder.canvas.label).to eq('none' => ['Test Canvas'])
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
