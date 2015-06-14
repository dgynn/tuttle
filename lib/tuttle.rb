require 'tuttle/engine'
require 'tuttle/version'

module Tuttle

  mattr_accessor :automount_engine
  mattr_accessor :enabled
  mattr_accessor :track_notifications

  @@automount_engine = @@enabled = @@track_notifications = false

  def self.setup
    yield self
  end

end
