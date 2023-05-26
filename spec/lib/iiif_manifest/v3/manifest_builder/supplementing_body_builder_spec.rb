# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::V3::ManifestBuilder::SupplementingBodyBuilder do
  let(:builder) do
    described_class.new(
      supplementing_content,
      iiif_body_factory: IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
    )
  end
  let(:url) { 'http://example.com/caption.vtt' }
  let(:supplementing_content) { IIIFManifest::V3::SupplementingContent.new(url, label: 'English', type: 'Text', format: 'text/vtt', language: 'eng') }
  let(:annotation) { IIIFManifest::V3::ManifestBuilder::IIIFManifest::Annotation.new }

  describe '#apply' do
    subject { builder.apply(annotation) }

    it 'sets a body on the annotation' do
      subject
      expect(annotation.body).to be_kind_of IIIFManifest::V3::ManifestBuilder::IIIFManifest::Body
      expect(annotation.body['id']).to eq url
      expect(annotation.body['type']).to eq 'Text'
      expect(annotation.body['format']).to eq 'text/vtt'
      expect(annotation.body['label']).to eq({ "none" => ["English"] })
      expect(annotation.body['language']).to eq 'eng'
    end
  end
end
