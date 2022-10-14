# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestFactory do
  subject { described_class.new(book_presenter) }

  let(:presenter_class) { Book }
  let(:book_presenter) { presenter_class.new('book-77') }

  before do
    class Book
      attr_reader :id, :label, :description

      def initialize(id, label: 'A good book', description: 'a brief description')
        @id = id
        @label = label
        @description = description
      end

      def file_set_presenters
        []
      end

      def work_presenters
        []
      end

      def manifest_url
        "http://test.host/books/#{id}/manifest"
      end

      def to_s
        label
      end

      def ranges
        @ranges ||=
          [
            ManifestRange.new(label: 'Table of Contents', ranges: [
                                ManifestRange.new(label: 'Chapter 1', file_set_presenters: [])
                              ])
          ]
      end
    end

    class AudioBook < Book
    end

    class ManifestRange
      attr_reader :label, :ranges, :file_set_presenters
      def initialize(label:, ranges: [], file_set_presenters: [])
        @label = label
        @ranges = ranges
        @file_set_presenters = file_set_presenters
      end
    end

    class DisplayImagePresenter
      attr_reader :id, :label
      def initialize(id: 'test-22', label: 'Page 1')
        @id = id
        @label = label
      end

      def to_s
        label
      end

      def display_image
        IIIFManifest::DisplayImage.new(
          'test.host/images/image-77/full/600,/0/default.jpg',
          width: 2000,
          height: 1500,
          format: 'image/jpeg',
          iiif_endpoint: IIIFManifest::IIIFEndpoint.new('test.host/images/image-77')
        )
      end
    end

    class AudioFilePresenter
      attr_reader :id, :label
      def initialize(id: 'test-22', label: 'Disc 1')
        @id = id
        @label = label
      end

      def to_s
        label
      end

      def display_content
        IIIFManifest::V3::DisplayContent.new(id, type: 'Sound', duration: 360_000, format: 'audio/mp4')
      end
    end
  end

  after do
    Object.send(:remove_const, :DisplayImagePresenter)
    Object.send(:remove_const, :AudioFilePresenter)
    Object.send(:remove_const, :AudioBook)
    Object.send(:remove_const, :Book)
  end

  describe '#to_h' do
    let(:result) { subject.to_h }
    let(:json_result) { JSON.parse(subject.to_h.to_json) }

    it 'has a label' do
      expect(result.label).to eq('none' => ['A good book'])
    end

    it 'has a summary' do
      expect(result.summary).to eq('none' => ['a brief description'])
    end

    context 'has a summary' do
      let(:book_presenter) { presenter_class.new('book-77', description: nil) }
      it 'which is nil when description is empty' do
        expect(result.summary).to eq(nil)
        expect(json_result.key?('summary')).to be false
      end
    end

    it 'has an ID' do
      expect(result['id']).to eq 'http://test.host/books/book-77/manifest'
    end

    context 'when there are no files' do
      it 'returns no items' do
        expect(result['items']).to eq []
      end
    end

    context 'when there is a fileset' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'returns items' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])

        expect(result['items'].length).to eq 1
        expect(result['items'].first['type']).to eq 'Canvas'
        expect(result['items'].first['id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
        expect(result['items'].first['height']).to eq 1500
        expect(result['items'].first['width']).to eq 2000
        expect(result['items'].first['items'].first['type']).to eq 'AnnotationPage'
        expect(result['items'].first['items'].first['id']).not_to be_empty
        expect(result['items'].first['items'].first['items'].length).to eq 1
        expect(result['items'].first['items'].first['items'].first['type']).to eq 'Annotation'
        expect(result['items'].first['items'].first['items'].first['id']).not_to be_empty
        expect(result['items'].first['items'].first['items'].first['motivation']).to eq 'painting'
        expect(result['items'].first['items'].first['items'].first['target']).to eq result['items'].first['id']
        expect(result['items'].first['items'].first['items'].first['body']['type']).to eq 'Image'
        expect(result['items'].first['items'].first['items'].first['body']['id']).not_to be_empty
        expect(result['items'].first['items'].first['items'].first['body']['height']).to eq 1500
        expect(result['items'].first['items'].first['items'].first['body']['width']).to eq 2000
        expect(result['items'].first['items'].first['items'].first['body']['format']).to eq 'image/jpeg'
      end

      it 'has a thumbnail property' do
        allow(book_presenter).to receive(:member_presenters).and_return([file_presenter])

        thumbnail = result['thumbnail'].first
        expect(thumbnail['id']).to eq 'test.host/images/image-77/full/!200,200/0/default.jpg'
        expect(thumbnail['height']).to eq 150
        expect(thumbnail['width']).to eq 200
        expect(thumbnail['format']).to eq 'image/jpeg'
        expect(thumbnail['service'].first).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFService
      end

      it 'builds a structure if it can' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        allow(book_presenter.ranges[0].ranges[0]).to receive(:file_set_presenters).and_return([file_presenter])

        expect(result['structures'].length).to eq 1
        structure = result['structures'].first
        expect(structure['label']).to eq('none' => ['Table of Contents'])
        expect(structure['behavior']).to eq 'top'
        expect(structure['items'].length).to eq 1
        sub_range = structure['items'][0]
        expect(sub_range['type']).to eq 'Range'
        expect(sub_range['items'].length).to eq 1
        expect(sub_range['items'][0]['type']).to eq 'Canvas'
        expect(sub_range['items'][0]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
      end

      context 'with audio file' do
        let(:presenter_class) { AudioBook }
        let(:file_presenter) { AudioFilePresenter.new }

        it 'returns items' do
          allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])

          expect(result['items'].length).to eq 1
          expect(result['items'].first['type']).to eq 'Canvas'
          expect(result['items'].first['id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
          expect(result['items'].first.key?('height')).to eq false
          expect(result['items'].first.key?('width')).to eq false
          expect(result['items'].first['duration']).to eq 360_000
          expect(result['items'].first['items'].first['type']).to eq 'AnnotationPage'
          expect(result['items'].first['items'].first['id']).not_to be_empty
          expect(result['items'].first['items'].first['items'].length).to eq 1
          expect(result['items'].first['items'].first['items'].first['type']).to eq 'Annotation'
          expect(result['items'].first['items'].first['items'].first['id']).not_to be_empty
          expect(result['items'].first['items'].first['items'].first['motivation']).to eq 'painting'
          expect(result['items'].first['items'].first['items'].first['target']).to eq result['items'].first['id']
          expect(result['items'].first['items'].first['items'].first['body']['type']).to eq 'Sound'
          expect(result['items'].first['items'].first['items'].first['body']['id']).not_to be_empty
          expect(result['items'].first['items'].first['items'].first['body'].key?('height')).to eq false
          expect(result['items'].first['items'].first['items'].first['body'].key?('width')).to eq false
          expect(result['items'].first['items'].first['items'].first['body']['duration']).to eq 360_000
          expect(result['items'].first['items'].first['items'].first['body']['format']).to eq 'audio/mp4'
        end
      end
    end

    context 'when there is no sequence_rendering method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'does not have a rendering on the sequence' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        expect(result.key?('rendering')).to be false
      end
    end

    context 'when there is a sequence_rendering method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      before do
        class Book
          attr_reader :id

          def initialize(id)
            @id = id
          end

          def description
            'a brief description'
          end

          def file_set_presenters
            []
          end

          def work_presenters
            []
          end

          def manifest_url
            "http://test.host/books/#{id}/manifest"
          end

          def sequence_rendering
            [{ '@id' => 'http://test.host/file_set/id/download',
               'format' => 'application/pdf',
               'label' => 'Download' }]
          end
        end
      end

      it 'has a rendering on the canvas' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])

        expect(result['rendering']).to eq [{
          'id' => 'http://test.host/file_set/id/download',
          'format' => 'application/pdf',
          'label' => { 'none' => ['Download'] }
        }]
      end
    end

    context 'when there are no rights on the presenter' do
      it 'does not have a rights element' do
        allow(book_presenter).to receive(:rights_statement).and_return(nil)
        expect(result.key?('rights')).to be false
      end
    end

    context 'when there are a rights on the presenter' do
      it 'does have a rights element as a String' do
        allow(book_presenter).to receive(:rights_statement).and_return('the rights')
        expect(result['rights'].class).to eq String
      end

      context 'when the rights on the presenter is an Array' do
        it 'still has a rights element as a String' do
          allow(book_presenter).to receive(:rights_statement).and_return(['the rights'])
          expect(result['rights'].class).not_to eq Array
          expect(result['rights'].class).to eq String
        end
      end
    end

    context 'when there is no manifest_metadata method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'does not have a metadata element' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        expect(result.key?('metadata')).to be false
      end
    end

    context 'when there is a manifest_metadata method' do
      context 'with invalid data' do
        let(:metadata) { 'invalid data' }

        it 'has no metadata' do
          allow(book_presenter).to receive(:manifest_metadata).and_return(metadata)
          expect(result.key?('metadata')).to be false
        end
      end

      context 'with presentation 2 style metadata' do
        let(:metadata) { [{ 'label' => 'Title', 'value' => 'Title of the Item' }] }

        it 'has metadata' do
          allow(book_presenter).to receive(:manifest_metadata).and_return(metadata)
          expect(result['metadata'][0]['label']).to eq('none' => ['Title'])
          expect(result['metadata'][0]['value']).to eq('none' => ['Title of the Item'])
        end
      end

      context 'with presentation 3 style metadata' do
        let(:metadata) { [{ 'label' => { '@en' => ['Title'] }, 'value' => { '@en' => ['Title of the Item'] } }] }

        it 'has metadata' do
          allow(book_presenter).to receive(:manifest_metadata).and_return(metadata)
          expect(result['metadata'][0]['label']).to eq('@en' => ['Title'])
          expect(result['metadata'][0]['value']).to eq('@en' => ['Title of the Item'])
        end
      end
    end

    context 'when there is no search_service method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'does not have a service element' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        expect(result['service']).to eq nil
      end
    end

    context 'when there is a search_service method' do
      let(:search_service) { 'http://test.host/books/book-77/search' }

      it 'has a service element with the correct profile, id and without an embedded service element' do
        allow(book_presenter).to receive(:search_service).and_return(search_service)
        expect(result['service'][0]['profile']).to eq 'http://iiif.io/api/search/1/search'
        expect(result['service'][0]['id']).to eq 'http://test.host/books/book-77/search'
        expect(result['service'][0]['label']).to eq 'Search within this manifest'
        expect(result['service'][0]['type']).to eq 'SearchService1'
        expect(result['service'][0]['service']).to eq nil
      end
    end

    context 'when there is a search_service method that returns nil' do
      let(:search_service) { '' }

      it 'has no service' do
        allow(book_presenter).to receive(:search_service).and_return(search_service)
        expect(result['service']).to eq nil
      end
    end

    context 'when there is an autocomplete_service method' do
      let(:search_service) { 'http://test.host/books/book-77/search' }
      let(:autocomplete_service) { 'http://test.host/books/book-77/autocomplete' }

      it 'has a service element within the first service containing id and profile for the autocomplete service' do
        allow(book_presenter).to receive(:search_service).and_return(search_service)
        allow(book_presenter).to receive(:autocomplete_service).and_return(autocomplete_service)
        expect(result['service'][0]['service']['id']).to eq 'http://test.host/books/book-77/autocomplete'
        expect(result['service'][0]['service']['profile']).to eq 'http://iiif.io/api/search/1/autocomplete'
        expect(result['service'][0]['service']['label']).to eq 'Get suggested words in this manifest'
        expect(result['service'][0]['service']['type']).to eq 'AutoCompleteService1'
      end
    end

    context 'when there is no autocomplete_service method' do
      let(:search_service) { 'http://test.host/books/book-77/search' }

      it 'has a service element within the first service' do
        allow(book_presenter).to receive(:search_service).and_return(search_service)
        expect(result['service'][0]['service']).to eq nil
      end
    end

    context 'when there is an autocomplete_service method but no search service' do
      let(:autocomplete_service) { 'http://test.host/books/book-77/autocomplete' }

      it 'has a service element within the first service' do
        allow(book_presenter).to receive(:autocomplete_service).and_return(autocomplete_service)
        expect(result['service']).to eq nil
      end
    end

    context 'when there are child works' do
      let(:child_work_presenter) { presenter_class.new('test2', label: 'Inner book') }

      before do
        allow(book_presenter).to receive(:work_presenters).and_return([child_work_presenter])
      end
      it 'returns a IIIF Collection' do
        expect(result['type']).to eq 'Collection'
        expect(result['label']).to eq('none' => ['A good book'])
      end
      it "doesn't build sequences" do
        expect(result['sequences']).to eq nil
      end
      it 'has a multi-part viewing hint' do
        expect(json_result['behavior']).to eq 'multi-part'
      end
      it 'builds child manifests' do
        expect(result['manifests'].length).to eq 1
        first_child = result['manifests'].first
        expect(first_child['id']).to eq 'http://test.host/books/test2/manifest'
        expect(first_child['type']).to eq 'Manifest'
        expect(first_child['label']).to eq('none' => ['Inner book'])
      end
    end

    context 'when there are child works AND files' do
      let(:child_work_presenter) { presenter_class.new('test-99') }
      let(:file_presenter) { DisplayImagePresenter.new(id: 'test-22') }
      let(:file_presenter2) { DisplayImagePresenter.new(id: 'test-33', label: 'Page 2') }
      let(:chapter_1_range) { ManifestRange.new(label: 'Chapter 1', file_set_presenters: [file_presenter]) }
      let(:child_work_range) { ManifestRange.new(label: 'Child Work', file_set_presenters: [file_presenter2]) }

      before do
        allow(book_presenter).to receive(:work_presenters).and_return([child_work_presenter])
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        allow(child_work_presenter).to receive(:file_set_presenters).and_return([file_presenter2])
        allow(child_work_presenter).to receive(:ranges).and_return([child_work_range])
        allow(book_presenter.ranges[0]).to receive(:ranges).and_return([chapter_1_range] + child_work_presenter.ranges)
      end
      it 'returns a IIIF Manifest' do
        expect(result['type']).to eq 'Manifest'
      end
      it "doesn't build manifests" do
        expect(result.key?('manifest')).to be false
      end
      it 'builds items array from all the child file sets' do
        expect(result['items'].length).to eq 2
      end
      it 'builds structures from all the child file sets' do
        expect(result['structures'].first['items'].length).to eq 2
        expect(result['structures'].first['items'][0]['items'].first['type']).to eq 'Canvas'
        expect(result['structures'].first['items'][0]['items'].first['id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
        expect(result['structures'].first['items'][1]['items'].first['type']).to eq 'Canvas'
        expect(result['structures'].first['items'][1]['items'].first['id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-33'
      end
    end

    context 'when there are child works AND when the work identifies itself as a sammelband' do
      let(:child_work_presenter) { presenter_class.new('test-99') }
      let(:file_presenter) { DisplayImagePresenter.new }

      before do
        allow(book_presenter).to receive(:sammelband?).and_return(true)
        allow(book_presenter).to receive(:work_presenters).and_return([child_work_presenter])
        allow(child_work_presenter).to receive(:file_set_presenters).and_return([file_presenter])
      end
      it 'returns a IIIF Manifest' do
        expect(result['type']).to eq 'Manifest'
      end
      it "doesn't build manifests" do
        expect(result.key?('manifest')).to be false
      end
      it 'builds items array from all the child file sets' do
        expect(result['items'].length).to eq 1
      end
    end

    context 'when there is no viewing_direction method' do
      it 'does not have a viewingDirection element' do
        expect(result['viewingDirection']).to eq nil
      end
    end

    context 'when there is a viewing_direction method' do
      it 'has a viewingDirection' do
        allow(book_presenter).to receive(:viewing_direction).and_return('right-to-left')
        expect(result.viewingDirection).to eq 'right-to-left'
      end
    end

    context 'when there is display_content' do
      before do
        class DisplayContentPresenter
          attr_reader :id, :label, :content
          def initialize(id: 'test-22', label: 'Section 1', content:)
            @id = id
            @label = label
            @content = content
          end

          def to_s
            label
          end

          def display_content
            content
          end
        end

        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
      end

      after do
        Object.send(:remove_const, :DisplayContentPresenter)
      end

      let(:file_presenter) { DisplayContentPresenter.new(content: content) }
      let(:content_annotation_body) { result['items'].first['items'].first['items'].first['body'] }

      context 'with a DisplayImage' do
        let(:content) do
          IIIFManifest::DisplayImage.new(SecureRandom.uuid, width: 100,
                                                            height: 100,
                                                            format: 'image/jpeg')
        end

        it 'returns items' do
          expect(content_annotation_body['type']).to eq 'Image'
          expect(content_annotation_body['id']).not_to be_empty
          expect(content_annotation_body['height']).to eq 100
          expect(content_annotation_body['width']).to eq 100
          expect(content_annotation_body['format']).to eq 'image/jpeg'
        end
      end

      context 'with a single file' do
        let(:content) do
          IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, width: 100,
                                                                  height: 100,
                                                                  duration: 100,
                                                                  type: 'Video',
                                                                  format: 'video/mp4',
                                                                  label: 'High')
        end

        it 'returns items' do
          expect(content_annotation_body['type']).to eq 'Video'
          expect(content_annotation_body['id']).not_to be_empty
          expect(content_annotation_body['height']).to eq 100
          expect(content_annotation_body['width']).to eq 100
          expect(content_annotation_body['format']).to eq 'video/mp4'
          expect(content_annotation_body['duration']).to eq 100
          expect(content_annotation_body['label']).to eq('none' => ['High'])
        end

        context 'with audio file' do
          let(:content) do
            IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, duration: 100,
                                                                    type: 'Sound',
                                                                    format: 'audio/mp4',
                                                                    label: 'High')
          end

          it 'returns items' do
            expect(content_annotation_body['type']).to eq 'Sound'
            expect(content_annotation_body['id']).not_to be_empty
            expect(content_annotation_body.key?('height')).to eq false
            expect(content_annotation_body.key?('width')).to eq false
            expect(content_annotation_body['format']).to eq 'audio/mp4'
            expect(content_annotation_body['duration']).to eq 100
            expect(content_annotation_body['label']).to eq('none' => ['High'])
          end
        end
      end

      context 'with multiple files' do
        let(:content) do
          [IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, type: 'Video',
                                                                   label: 'High',
                                                                   width: 100,
                                                                   height: 100,
                                                                   duration: 100,
                                                                   format: 'video/mp4'),
           IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, type: 'Video',
                                                                   label: 'Medium',
                                                                   width: 100,
                                                                   height: 100,
                                                                   duration: 100,
                                                                   format: 'video/mp4'),
           IIIFManifest::V3::DisplayContent.new(SecureRandom.uuid, type: 'Video',
                                                                   label: 'Low',
                                                                   width: 100,
                                                                   height: 100,
                                                                   duration: 100,
                                                                   format: 'video/mp4')]
        end

        it 'returns items' do
          expect(content_annotation_body['type']).to eq 'Choice'
          expect(content_annotation_body['choiceHint']).to eq 'user'
          expect(content_annotation_body.items.size).to eq 3
          content_annotation_body.items.each do |choice|
            expect(choice['type']).to eq 'Video'
            expect(choice['id']).not_to be_empty
            expect(choice['width']).to eq 100
            expect(choice['height']).to eq 100
            expect(choice['format']).to eq 'video/mp4'
            expect(choice['duration']).to eq 100
            expect(choice['label']['none']).not_to be_empty
          end
        end
      end
    end

    context 'when there is a homepage' do
      before do
        class BookWithHomepage
          attr_reader :id, :label, :description

          def initialize(id, label: 'A good book', description: 'a brief description')
            @id = id
            @label = label
            @description = description
          end

          def file_set_presenters
            []
          end

          def work_presenters
            []
          end

          def manifest_url
            "http://test.host/books/#{id}/manifest"
          end

          def to_s
            label
          end

          def homepage
            {
              id: "https://example.com/info/",
              type: "Text",
              label: { "en" => ["Homepage for Example Object"] },
              format: "text/html"
            }
          end
        end
      end

      after do
        Object.send(:remove_const, :BookWithHomepage)
      end

      let(:presenter_class) { BookWithHomepage }

      it 'includes the homepage in the manifest' do
        homepage = json_result["homepage"]
        expect(homepage['id']).to eq "https://example.com/info/"
        expect(homepage['format']).to eq "text/html"
        expect(homepage['type']).to eq "Text"
        expect(homepage['label']['en']).to eq ["Homepage for Example Object"]
      end
    end
  end
end
