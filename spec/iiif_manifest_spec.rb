# frozen_string_literal: true
require 'spec_helper'

describe IIIFManifest do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end
  it 'is configurable' do
    expect(described_class.config).to be_a described_class::Configuration
  end
end
