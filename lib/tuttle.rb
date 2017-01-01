require 'tuttle/version'

# TODO: clean this up so that mattr_accessor is not needed
require 'active_support/core_ext/module/attribute_accessors'

module Tuttle
  mattr_accessor :automount_engine
  mattr_accessor :enabled
  mattr_accessor :track_notifications

  autoload :Instrumenter, 'tuttle/instrumenter'

  def self.setup
    yield self
  end
end

require 'tuttle/engine' if defined?(Rails)
