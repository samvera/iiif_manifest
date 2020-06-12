# frozen_string_literal: true
require 'spec_helper'

describe IIIFManifest do
  it 'has a version number' do
    expect(IIIFManifest::VERSION).not_to be nil
  end
end
