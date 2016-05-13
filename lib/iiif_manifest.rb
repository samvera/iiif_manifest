require "iiif_manifest/version"
require 'active_support'
require 'active_support/core_ext/module'
require 'active_support/core_ext/object'
require 'iiif/presentation' # AKA O'Sullivan

module IIIFManifest
  extend ActiveSupport::Autoload
  autoload :ManifestBuilder
  autoload :ManifestFactory
  autoload :ManifestServiceLocator
  autoload :ManifestHelper
  autoload :DisplayImage
  autoload :IIIFCollection
  autoload :IIIFEndpoint
end
