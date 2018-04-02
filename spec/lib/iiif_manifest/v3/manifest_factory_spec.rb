require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestFactory do
  subject { described_class.new(book_presenter) }

  let(:presenter_class) { Book }
  let(:book_presenter) { presenter_class.new('book-77') }

  before do
    class Book
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
        "http://test.host/books/#{@id}/manifest"
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

    class ManifestRange
      attr_reader :label, :ranges, :file_set_presenters
      def initialize(label:, ranges: [], file_set_presenters: [])
        @label = label
        @ranges = ranges
        @file_set_presenters = file_set_presenters
      end
    end

    class DisplayImagePresenter
      def initialize(id: 'test-22')
        @id = id
      end

      def id
        @id
      end

      def display_image
        IIIFManifest::DisplayImage.new(id, width: 100, height: 100, format: 'image/jpeg')
      end
    end
  end

  after do
    Object.send(:remove_const, :DisplayImagePresenter)
    Object.send(:remove_const, :Book)
  end

  describe '#to_h' do
    let(:result) { subject.to_h }
    let(:json_result) { JSON.parse(subject.to_h.to_json) }

    it 'has a label' do
      expect(result.label).to eq book_presenter.to_s
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

      it 'returns a sequence' do
        allow(IIIFManifest::V3::ManifestBuilder::CanvasBuilder).to receive(:new).and_call_original
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])

        result

        expect(IIIFManifest::V3::ManifestBuilder::CanvasBuilder).to have_received(:new)
          .exactly(1).times.with(file_presenter, anything, anything)
        expect(result['items'].length).to eq 1
      end
      it 'builds a structure if it can' do
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        allow(book_presenter.ranges[0].ranges[0]).to receive(:file_set_presenters).and_return([file_presenter])

        expect(result['structures'].length).to eq 1
        structure = result['structures'].first
        expect(structure['label']).to eq 'Table of Contents'
        expect(structure['behavior']).to eq 'top'
        expect(structure['items'].length).to eq 1
        expect(structure['items'][0]['type']).to eq 'Range'
        sub_range = structure['items'][0]
        expect(sub_range['items'].length).to eq 1
        expect(sub_range['items'][0]['type']).to eq 'Canvas'
        expect(sub_range['items'][0]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
      end
    end

    context 'when there is no sequence_rendering method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'does not have a rendering on the sequence' do
        allow(IIIFManifest::V3::ManifestBuilder::CanvasBuilder).to receive(:new).and_call_original
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        expect(result['rendering']).to eq []
      end
    end

    context 'when there is a sequence_rendering method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      before do
        class Book
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
            "http://test.host/books/#{@id}/manifest"
          end

          def sequence_rendering
            [{ '@id' => 'http://test.host/file_set/id/download',
               'format' => 'application/pdf',
               'label' => 'Download' }]
          end
        end
      end

      it 'has a rendering on the sequence' do
        allow(IIIFManifest::V3::ManifestBuilder::CanvasBuilder).to receive(:new).and_call_original
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])

        expect(result['rendering']).to eq [{
          'id' => 'http://test.host/file_set/id/download', 'format' => 'application/pdf', 'label' => 'Download'
        }]
      end
    end

    context 'when there is no manifest_metadata method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'does not have a metadata element' do
        allow(IIIFManifest::V3::ManifestBuilder::CanvasBuilder).to receive(:new).and_call_original
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        expect(result['metadata']).to eq nil
      end
    end

    context 'when there is a manifest_metadata method' do
      let(:metadata) { [{ 'label' => 'Title', 'value' => 'Title of the Item' }] }

      it 'has metadata' do
        allow(book_presenter).to receive(:manifest_metadata).and_return(metadata)
        expect(result['metadata'][0]['label']).to eq 'Title'
        expect(result['metadata'][0]['value']).to eq 'Title of the Item'
      end
    end

    context 'when there is a manifest_metadata method with invalid data' do
      let(:metadata) { 'invalid data' }

      it 'has no metadata' do
        allow(book_presenter).to receive(:manifest_metadata).and_return(metadata)
        expect(result['metadata']).to eq nil
      end
    end

    context 'when there is no search_service method' do
      let(:file_presenter) { DisplayImagePresenter.new }

      it 'does not have a service element' do
        allow(IIIFManifest::V3::ManifestBuilder::CanvasBuilder).to receive(:new).and_call_original
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
      let(:child_work_presenter) { presenter_class.new('test2') }

      before do
        allow(book_presenter).to receive(:work_presenters).and_return([child_work_presenter])
      end
      it 'returns a IIIF Collection' do
        expect(result['type']).to eq 'Collection'
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
        expect(first_child['label']).to eq child_work_presenter.to_s
      end
    end

    context 'when there are child works AND files' do
      let(:child_work_presenter) { presenter_class.new('test-99') }
      let(:file_presenter) { DisplayImagePresenter.new(id: 'test-22') }
      let(:file_presenter2) { DisplayImagePresenter.new(id: 'test-33') }

      before do
        allow(book_presenter).to receive(:work_presenters).and_return([child_work_presenter])
        allow(book_presenter).to receive(:file_set_presenters).and_return([file_presenter])
        allow(child_work_presenter).to receive(:file_set_presenters).and_return([file_presenter2])
        allow(child_work_presenter).to receive(:ranges).and_return([ManifestRange.new(label: 'Child Work', file_set_presenters: [file_presenter2])])
        allow(book_presenter.ranges[0]).to receive(:ranges).and_return([ManifestRange.new(label: 'Chapter 1', file_set_presenters: [file_presenter])] + child_work_presenter.ranges)
      end
      it 'returns a IIIF Manifest' do
        expect(result['type']).to eq 'Manifest'
      end
      it "doesn't build manifests" do
        expect(result['manifests']).to eq nil
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
        expect(result['manifests']).to eq nil
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
  end
end
