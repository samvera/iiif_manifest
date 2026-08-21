# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::ManifestBuilder::CanvasBuilder do
  let(:builder) do
    described_class.new(
      record,
      parent,
      iiif_canvas_factory: IIIFManifest::ManifestBuilder::IIIFManifest::Canvas,
      image_builder: IIIFManifest::ManifestServiceLocator.image_builder
    )
  end
  let(:record) { MyWork.new }
  let(:parent) { MyParent.new }

  before do
    class MyWork
      def id
        'test-22'
      end

      def to_s
        'Test Work'
      end
    end

    class MyParent
      def manifest_url
        'http://test.host/books/book-77/manifest'
      end
    end
  end

  after do
    Object.send(:remove_const, :MyWork)
    Object.send(:remove_const, :MyParent)
  end

  describe '#canvas' do
    it 'sets the id and label' do
      values = builder.canvas.inner_hash

      expect(values['@id']).to eq 'http://test.host/books/book-77/manifest/canvas/test-22'
      expect(values['label']).to eq 'Test Work'
    end

    context 'when the record has no item_metadata method' do
      it 'does not have a metadata element' do
        expect(builder.canvas.inner_hash).not_to include 'metadata'
      end
    end

    context 'when the record has item_metadata' do
      before do
        class MyWork
          def item_metadata
            [{ 'label' => 'Title', 'value' => 'Title of the Item' }]
          end
        end
      end

      it 'has metadata' do
        values = builder.canvas.inner_hash

        expect(values['metadata']).to eq [{ 'label' => 'Title', 'value' => 'Title of the Item' }]
      end
    end

    context 'when the item_metadata is missing required keys' do
      before do
        class MyWork
          def item_metadata
            [{ 'label' => 'Title' }]
          end
        end
      end

      it 'does not have a metadata element' do
        expect(builder.canvas.inner_hash).not_to include 'metadata'
      end
    end

    context 'when the item_metadata is not an array' do
      before do
        class MyWork
          def item_metadata
            'Title of the Item'
          end
        end
      end

      it 'does not have a metadata element' do
        expect(builder.canvas.inner_hash).not_to include 'metadata'
      end
    end
  end
end
