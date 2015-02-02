require 'tuttle/engine'

module Tuttle

  mattr_accessor :automount_engine
  mattr_accessor :enabled

  def self.setup
    yield self
  end

end
