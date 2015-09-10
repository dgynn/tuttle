require 'tuttle/engine'

module Tuttle

  autoload :Version, 'tuttle/version'

  mattr_accessor :automount_engine
  mattr_accessor :enabled
  mattr_accessor :track_notifications

  @@automount_engine = @@enabled = nil
  @@track_notifications = false

  def self.setup
    yield self
  end

end
