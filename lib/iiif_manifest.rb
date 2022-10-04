require 'iiif_manifest/version'
require 'active_support'
require 'active_support/core_ext/module'
require 'active_support/core_ext/object'

module IIIFManifest
  extend ActiveSupport::Autoload
  autoload :Configuration
  autoload :ManifestBuilder
  autoload :ManifestFactory
  autoload :ManifestServiceLocator
  autoload :DisplayImage
  autoload :IIIFCollection
  autoload :IIIFEndpoint
  autoload :V3

  ##
  # @api public
  #
  # Exposes the IIIFManifest configuration
  #
  # @yield [IIIFManifest::Configuration] if a block is passed
  # @return [IIIFManifest::Configuration]
  # @see IIIFManifest::Configuration for configuration options
  def self.config(&block)
    @config ||= IIIFManifest::Configuration.new

    yield @config if block

    @config
  end
end
