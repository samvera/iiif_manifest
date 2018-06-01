require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::StructureBuilder do
  let(:builder) do
    described_class.new(
      record,
      canvas_builder_factory: IIIFManifest::ManifestServiceLocator.canvas_builder,
      iiif_range_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Range
    )
  end
  let(:ranges) do
    []
  end
  let(:record) { double(manifest_url: 'http://test.host/books/book-77/manifest', ranges: ranges) }
  let(:manifest) { IIIFManifest::V3::ManifestBuilder::IIIFManifest.new }

  describe '#apply' do
    subject { builder.apply(manifest) }

    it 'returns a canvas url' do
      subject
      expect(manifest['structures']).to eq nil
    end

    context 'with ranges and file set presenters defined' do
      let(:ranges) do
        [
          ManifestRange.new(label: 'Table of Contents', ranges: [
                              ManifestRange.new(label: 'Chapter 1', file_set_presenters: file_set_presenters)
                            ],
                            file_set_presenters: [double(id: 'Front-Cover')])
        ]
      end
      let(:file_set_presenters) { [double(id: 'Page-1'), double(id: 'Page-2')] }

      before do
        class ManifestRange
          attr_reader :label, :ranges, :file_set_presenters
          def initialize(label:, ranges: [], file_set_presenters: [])
            @label = label
            @ranges = ranges
            @file_set_presenters = file_set_presenters
          end
        end
      end

      after do
        Object.send(:remove_const, :ManifestRange)
      end

      it 'builds the structure' do
        subject
        top_range = manifest['structures'].first
        expect(top_range['label']).to eq 'Table of Contents'
        expect(top_range['behavior']).to eq 'top'
        expect(top_range['items'].length).to eq 2
        expect(top_range['items'][0]['type']).to eq 'Canvas'
        expect(top_range['items'][0]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Front-Cover'
        expect(top_range['items'][1]['type']).to eq 'Range'
        sub_range = top_range['items'][1]
        expect(sub_range['items'].length).to eq 2
        expect(sub_range['items'][0]['type']).to eq 'Canvas'
        expect(sub_range['items'][0]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Page-1'
        expect(sub_range['items'][1]['type']).to eq 'Canvas'
        expect(sub_range['items'][1]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Page-2'
      end
    end

    context 'with items defined' do
      let(:ranges) do
        [
          ManifestRange.new(label: 'Table of Contents', items: [
                              double(id: 'Front-Cover'),
                              ManifestRange.new(label: 'Chapter 1', items: [
                                                  double(id: 'Page-1'),
                                                  double(id: 'Page-2')
                                                ]),
                              double(id: 'Back-Cover')
                            ])
        ]
      end

      before do
        class ManifestRange
          attr_reader :label, :items
          def initialize(label:, items: [])
            @label = label
            @items = items
          end
        end
      end

      after do
        Object.send(:remove_const, :ManifestRange)
      end

      it 'builds the structure' do
        subject
        top_range = manifest['structures'].first
        expect(top_range['label']).to eq 'Table of Contents'
        expect(top_range['behavior']).to eq 'top'
        expect(top_range['items'].length).to eq 3
        expect(top_range['items'][0]['type']).to eq 'Canvas'
        expect(top_range['items'][0]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Front-Cover'
        expect(top_range['items'][1]['type']).to eq 'Range'
        sub_range = top_range['items'][1]
        expect(sub_range['items'].length).to eq 2
        expect(sub_range['items'][0]['type']).to eq 'Canvas'
        expect(sub_range['items'][0]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Page-1'
        expect(sub_range['items'][1]['type']).to eq 'Canvas'
        expect(sub_range['items'][1]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Page-2'
        expect(top_range['items'][2]['type']).to eq 'Canvas'
        expect(top_range['items'][2]['id']).to eq 'http://test.host/books/book-77/manifest/canvas/Back-Cover'
      end
    end
  end
end
