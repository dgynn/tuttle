require 'rails'
require 'rails/engine'

module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    config.tuttle = ActiveSupport::OrderedOptions.new

    mattr_accessor :reload_needed
    mattr_accessor :session_start, :session_id

    mattr_reader :logger

    initializer 'tuttle' do |app|

      app.config.tuttle.each do |k, v|
        puts "Got tuttle key #{k}"
        Tuttle.send("#{k}=", v)
      end

      # Tuttle will be enabled automatically in development if not configured explicitly
      Tuttle.enabled = Rails.env.development? if Tuttle.enabled.nil?

      next unless Tuttle.enabled

      Tuttle::Engine.session_start = Time.now
      Tuttle::Engine.session_id = SecureRandom.uuid
      @@logger = ::Logger.new("#{Rails.root}/log/tuttle.log")
      self.logger.info('Tuttle engine started')

      ActionDispatch::Reloader.to_prepare do
        Tuttle::Engine.logger.warn('ActionDispatch::Reloader called to_prepare') unless Tuttle::Engine.reload_needed.nil?
        Tuttle::Engine.reload_needed = true
      end

      Tuttle.automount_engine = true if Tuttle.automount_engine==nil

      if Tuttle.automount_engine
        Rails.application.routes.prepend do
          Tuttle::Engine.logger.info('Auto-mounting /tuttle routes')
          mount Tuttle::Engine, at: "tuttle"
        end
      end

      if Tuttle.track_notifications
        Tuttle::Instrumenter.initialize_tuttle_instrumenter
      end

    end

  end
end
