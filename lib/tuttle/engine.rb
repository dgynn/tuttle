require 'tuttle'
require 'rails/engine'

module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    attr_accessor :reload_needed, :session_start, :session_id

    attr_reader :logger

    config.tuttle = ActiveSupport::OrderedOptions.new

    config.before_configuration do
      Tuttle::Engine.session_start = Time.current
      Tuttle::Engine.session_id = SecureRandom.uuid
    end

    initializer 'tuttle' do |app|
      app.config.tuttle.each do |k, v|
        Tuttle.send("#{k}=", v)
      end

      # Tuttle will be enabled automatically in development if not configured explicitly
      Tuttle.enabled = Rails.env.development? if Tuttle.enabled.nil?

      next unless Tuttle.enabled

      @logger = ::Logger.new("#{Rails.root}/log/tuttle.log")
      Tuttle::Engine.logger.info('Tuttle engine started')

      Tuttle.automount_engine = true if Tuttle.automount_engine.nil?

      if Tuttle.automount_engine
        Rails.application.routes.prepend do
          Tuttle::Engine.logger.info('Auto-mounting /tuttle routes')
          mount Tuttle::Engine, at: 'tuttle'
        end
      end

      if Tuttle.track_notifications
        Tuttle::Instrumenter.initialize_tuttle_instrumenter
      end
    end

    config.to_prepare do
      Tuttle::Engine.reload_needed = true
    end

  end
end
