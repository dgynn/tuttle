require 'tuttle/engine'

module Tuttle

  mattr_accessor :automount_engine
  @@automount_engine = true

  def self.setup
    yield self
  end

end
