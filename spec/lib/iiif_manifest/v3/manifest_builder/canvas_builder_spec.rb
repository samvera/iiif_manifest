# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::CanvasBuilder do
  let(:content_builder) do
    IIIFManifest::V3::ManifestBuilder::ContentBuilder
  end
  let(:annotation_content_builder) do
    IIIFManifest::V3::ManifestBuilder::AnnotationContentBuilder
  end
  let(:see_also) { { id: '1234.json', label: 'seeAlso' } }
  let(:builder) do
    described_class.new(
      record,
      parent,
      iiif_canvas_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas,
      content_builder: content_builder,
      choice_builder: IIIFManifest::V3::ManifestBuilder::ChoiceBuilder,
      annotation_content_builder: annotation_content_builder,
      iiif_annotation_page_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage,
      thumbnail_builder_factory: thumbnail_builder_factory,
      placeholder_canvas_builder_factory: placeholder_canvas_builder_factory
    )
  end

  let(:parent) { double(manifest_url: 'http://test.host/books/book-77/manifest') }

  after do
    Object.send(:remove_const, :MyWork)
  end

  let(:url) { 'http://example.com/img1.jpg' }
  let(:caption_url) { 'http://example.com/img1.jpg/caption.vtt' }
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
  let(:placeholder_content) do
    IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, type: 'Image',
                                                            width: 100,
                                                            height: 100,
                                                            format: 'image/jpeg')
  end
  let(:annotation_content) do
    IIIFManifest::V3::AnnotationContent.new(body_id: caption_url,
                                            type: 'text',
                                            motivation: 'supplementing',
                                            format: 'text/vtt',
                                            label: 'English',
                                            language: 'eng')
  end
  let(:record) do
    MyWork.new(display_content: display_content,
               placeholder_content: placeholder_content,
               annotation_content: annotation_content)
  end

  before do
    class MyWork
      attr_reader :display_content, :placeholder_content, :annotation_content

      def initialize(display_content:, placeholder_content:, annotation_content:)
        @display_content = display_content
        @placeholder_content = placeholder_content
        @annotation_content = annotation_content
      end

      def id
        'test-22'
      end
    end

    allow(body_builder).to receive(:apply).and_return(iiif_body)
    allow(caption_body_builder).to receive(:apply).and_return(iiif_caption_body)
    allow(body_builder_factory).to receive(:new).and_return(body_builder)
    allow(caption_body_builder_factory).to receive(:new).and_return(caption_body_builder)
    allow(iiif_annotation_factory).to receive(:new).and_return(iiif_annotation)
    allow(iiif_caption_annotation_factory).to receive(:new).and_return(iiif_caption_annotation)
    allow(content_builder).to receive(:new).and_return(built_content)
    allow(annotation_content_builder).to receive(:new).and_return(built_annotation_content)
    allow(thumbnail_builder).to receive(:build).and_return(iiif_thumbnail)
    allow(thumbnail_builder_factory).to receive(:new).and_return(thumbnail_builder)
    allow(placeholder_canvas_builder).to receive(:build).and_return(placeholder_canvas)
    allow(placeholder_canvas_builder_factory).to receive(:new).and_return(placeholder_canvas_builder)
  end

  let(:iiif_body) do
    body = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body.new
    body['width'] = '100px'
    body['height'] = '100px'
    body['duration'] = nil
    body
  end

  let(:iiif_caption_body) do
    body = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body.new
    body['label'] = { "none" => ["English"] }
    body['language'] = 'eng'
    body['format'] = 'text/vtt'
    body
  end

  let(:iiif_thumbnail) do
    thumbnail = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail.new
    thumbnail['type'] = 'Image'
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

  let(:iiif_caption_annotation) do
    caption_annotation = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation.new
    caption_annotation.body = iiif_caption_body
    caption_annotation['motivation'] = 'supplementing'
    caption_annotation
  end

  let(:iiif_annotation_factory) do
    double('IIIF Annotation Factory')
  end

  let(:iiif_caption_annotation_factory) do
    double('IIIF Annotation Factory')
  end

  let(:body_builder) do
    instance_double(IIIFManifest::V3::ManifestBuilder::BodyBuilder)
  end

  let(:caption_body_builder) do
    instance_double(IIIFManifest::V3::ManifestBuilder::BodyBuilder)
  end

  let(:body_builder_factory) do
    double('Body Builder')
  end

  let(:caption_body_builder_factory) do
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

  let(:built_annotation_content) do
    IIIFManifest::V3::ManifestBuilder::AnnotationContentBuilder.new(
      record.annotation_content,
      iiif_annotation_factory: iiif_caption_annotation_factory,
      body_builder_factory: caption_body_builder_factory
    )
  end

  let(:content_builder) do
    double('Content Builder')
  end

  let(:annotation_content_builder) do
    double('Annotation Content Builder')
  end

  let(:placeholder_canvas_builder) do
    double('Placeholder Canvas Builder')
  end

  let(:placeholder_canvas_builder_factory) do
    double('PlaceholderCanvas Builder')
  end

  let(:placeholder_canvas) do
    placeholder_canvas = IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas.new
    placeholder_canvas['height'] = 100
    placeholder_canvas['width'] = 100
    placeholder_canvas['type'] = 'Canvas'
    placeholder_canvas['items'] = []
    placeholder_canvas
  end

  describe '#canvas' do
    context 'when the display content is populated for a record' do
      it 'generates the canvas' do
        canvas = builder.canvas
        expect(canvas).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
        canvas_values = canvas.inner_hash

        expect(canvas_values).to include "type" => "Canvas"
        expect(canvas_values).to include "id" => "http://test.host/books/book-77/manifest/canvas/test-22"
        expect(canvas_values).to include "items"
        expect(canvas_values).to include "annotations"
        expect(canvas_values).not_to include "seeAlso"

        expect(canvas_values).to include "thumbnail"
        thumbnail = canvas_values['thumbnail'].first
        expect(thumbnail).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Thumbnail
        thumbnail_values = thumbnail.inner_hash
        expect(thumbnail_values).to include "type" => "Image"
        expect(thumbnail_values).to include "width" => 200
        expect(thumbnail_values).to include "height" => 150

        items = canvas_values['items']
        expect(items.length).to eq 1
        page = items.first
        expect(page).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage
        items = page.items
        expect(items.length).to eq 1
        annotation = items.first
        expect(annotation).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation
        values = annotation.inner_hash
        expect(values).to include "motivation" => "painting"
        expect(values).to include('body')
        body = values['body']
        expect(body).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        values = body.inner_hash
        expect(values).to include "width" => "100px"
        expect(values).to include "height" => "100px"
        expect(values).to include "duration" => nil

        annotations = canvas_values['annotations']
        expect(annotations.length).to eq 1
        supplement_page = annotations.first
        expect(supplement_page).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::AnnotationPage
        supplement_items = supplement_page.items
        expect(supplement_items.length).to eq 1
        supplement_annotation = supplement_items.first
        expect(supplement_annotation).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation
        supplement_values = supplement_annotation.inner_hash
        expect(supplement_values).to include "motivation" => "supplementing"
        expect(supplement_values).to include('body')
        supplement_body = supplement_values['body']
        expect(supplement_body).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
        values = supplement_body.inner_hash
        expect(values).to include "label" => { "none" => ["English"] }
        expect(values).to include "format" => "text/vtt"
        expect(values).to include "language" => "eng"
      end
    end

    context 'when display content has no rendering sequence' do
      let(:display_content) do
        IIIFManifest::V3::DisplayContent.new(url,
                                             width: 640,
                                             height: 480,
                                             type: 'Image',
                                             format: 'image/jpeg',
                                             label: 'full',
                                             iiif_endpoint: iiif_endpoint)
      end
      it 'generates canvas without rendering property' do
        canvas = builder.canvas
        expect(canvas).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
        values = canvas.inner_hash
        expect(values.key?('rendering')).to be false
      end
    end

    context 'when record has see_also' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def see_also
            [{
              id: 'test-22.json',
              type: 'Dataset',
              label: 'test-22 see also'
            }]
          end
        end
      end
      it 'generates canvas with seeAlso property' do
        canvas = builder.canvas
        expect(canvas).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
        values = canvas.inner_hash
        expect(values.key?('seeAlso')).to be true
      end
    end

    context 'when record has part_of' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def part_of
            [{
              id: 'http://test.host/books/book-77/manifest',
              type: 'manifest'
            }]
          end
        end
      end
      it 'generates canvas with partOf property' do
        canvas = builder.canvas
        expect(canvas).to be_a IIIFManifest::V3::ManifestBuilder::IIIFManifest::Canvas
        values = canvas.inner_hash
        expect(values.key?('partOf')).to be true
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

        expect(values).to include 'annotations'
      end
    end

    context 'when annotation content is empty for an item' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def annotation_content
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
        expect(page.items).not_to be_empty

        expect(values).not_to include 'annotations'
      end
    end

    context 'when annotation content has more than one item' do
      let(:built_annotation_content) do
        IIIFManifest::V3::ManifestBuilder::AnnotationContentBuilder.new(
          record.annotation_content[0],
          iiif_annotation_factory: iiif_caption_annotation_factory,
          body_builder_factory: caption_body_builder_factory
        )
      end
      let(:annotation_content) do
        [IIIFManifest::V3::AnnotationContent.new(annotation_id: "http://highlight.mark",
                                                 type: 'TextualBody',
                                                 motivation: 'highlighting',
                                                 format: 'text/html',
                                                 value: 'marker',
                                                 media_fragment: 't=15'),
         IIIFManifest::V3::AnnotationContent.new(body_id: "http://transcript.vtt",
                                                 type: 'text',
                                                 motivation: 'supplementing',
                                                 format: 'text/vtt',
                                                 label: 'English',
                                                 language: 'eng'),
         IIIFManifest::V3::AnnotationContent.new(body_id: "http://caption.vtt",
                                                 type: 'text',
                                                 motivation: 'supplementing',
                                                 format: 'text/vtt',
                                                 label: 'English',
                                                 language: 'eng')]
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
        expect(page.items).not_to be_empty

        expect(values).to include 'annotations'
        annotations = values['annotations']
        expect(annotations.length).to eq 1
        annotation_page = annotations.first
        expect(annotation_page.items.length).to eq 3
        expect(annotation_page.items[0].inner_hash['id']).to eq "http://highlight.mark"
        expect(annotation_page.items[0].inner_hash['target']).to include '#t=15'
        expect(annotation_page.items[1].body.inner_hash['language']).to eq 'eng'
        expect(annotation_page.items[2].body.inner_hash['language']).to eq 'eng'
        expect(annotation_page.items).to all(be_a(IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation))
      end
    end

    context "when annotation_content has no annotation_id and no motivation" do
      let(:annotation_content) do
        IIIFManifest::V3::AnnotationContent.new(motivation: nil,
                                                type: 'TextualBody',
                                                format: 'text/html',
                                                value: 'marker',
                                                media_fragment: 't=15')
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
        expect(page.items).not_to be_empty

        expect(values).to include 'annotations'
        annotations = values['annotations']
        expect(annotations.length).to eq 1
        annotation_page = annotations.first
        expect(annotation_page.items[0].inner_hash['id']).to match(/.+\/annotation\/.+/)
        expect(annotation_page.items[0].inner_hash['target']).to include '#t=15'
        expect(annotation_page.items).to all(be_a(IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation))
      end
    end

    context 'when placeholder_content is specificed for a record' do
      it 'generates placeholderCanvas' do
        canvas = builder.canvas
        values = canvas.inner_hash

        expect(values).to include 'placeholderCanvas'
      end
    end

    context 'when the placeholder_content is not specified for a record' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def placeholder_content
            nil
          end
        end
      end

      it 'does not generate placeholderCanvas' do
        canvas = builder.canvas
        values = canvas.inner_hash

        expect(values).not_to include 'placeholderCanvas'
      end
    end

    context 'when there is no manifest_metadata method' do
      it 'does not have a metadata element' do
        canvas = builder.canvas
        values = canvas.inner_hash

        expect(values).not_to include 'metadata'
      end
    end

    context 'when there is an item_metadata method' do
      context 'with invalid data' do
        before do
          class MyWork
            def id
              'test-22'
            end

            def item_metdata
              nil
            end
          end
        end

        it 'does not have a metadata element' do
          canvas = builder.canvas
          values = canvas.inner_hash

          expect(values).not_to include 'metadata'
        end
      end

      context 'with presentation 2 style metadata' do
        before do
          class MyWork
            def id
              'test-22'
            end

            def item_metdata
              [{ 'label' => 'Title', 'value' => 'Title of the Item' }]
            end
          end
        end

        it 'does not have a metadata element' do
          canvas = builder.canvas
          values = canvas.inner_hash

          expect(values).not_to include 'metadata'
        end
      end

      context 'with presentation 3 style metadata' do
        before do
          class MyWork
            def id
              'test-22'
            end

            def item_metadata
              [{ 'label' => { 'en' => ['Title'] }, 'value' => { 'en' => ['Title of the Item'] } }]
            end
          end
        end

        it 'has metadata' do
          canvas = builder.canvas
          values = canvas.inner_hash

          expect(values['metadata'][0]['label']).to eq('en' => ['Title'])
          expect(values['metadata'][0]['value']).to eq('en' => ['Title of the Item'])
        end
      end
    end

    context 'when the description is specified for a record' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def description
            'Ipsum Lorem'
          end
        end
      end

      it 'sets summary for a canvas' do
        canvas = builder.canvas
        values = canvas.inner_hash

        expect(values['summary']).to eq('none' => ['Ipsum Lorem'])
      end
    end

    context 'when the homepage is specified for a record' do
      before do
        class MyWork
          def id
            'test-22'
          end

          def homepage
            [{
              id: 'http://example.com/test-22',
              type: 'Text',
              label: 'test-22 homepage'
            }]
          end
        end
      end

      it 'sets homepage for a canvas' do
        canvas = builder.canvas
        values = canvas.inner_hash

        expect(values.key?('homepage')).to be true
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
