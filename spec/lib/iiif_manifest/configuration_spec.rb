# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IIIFManifest::Configuration do
  context '#manifest_value_for' do
    subject(:config) { described_class.new }

    # rubocop:disable RSpec/VerifiedDoubles
    let(:record) { double('record', description: 'the description', abstract: 'the abstract') }
    # rubocop:enable RSpec/VerifiedDoubles
    context 'with default configuration' do
      it 'maps a record\'s description to summary' do
        expect(config.manifest_value_for(record, property: :summary)).to eq record.description
      end
      it 'returns nil when the record does not have the mapped property' do
        expect(config.manifest_value_for(record, property: :homepage)).to be_nil
      end
      it 'raises a KeyError when we have not configured the property' do
        expect { config.manifest_value_for(record, property: :obviously_missing) }.to raise_error(KeyError)
      end
    end

    context 'with configured map' do
      before do
        config.manifest_property_to_record_method_name_map = { summary: :abstract }
      end
      it 'maps according to the configuration' do
        expect(config.manifest_value_for(record, property: :summary)).to eq record.abstract
      end
    end
  end
end
