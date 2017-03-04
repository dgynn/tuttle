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

      @logger = ::Logger.new(Rails.root.join('log', 'tuttle.log'))
      Tuttle::Engine.logger.info('Tuttle engine started')

      Tuttle.automount_engine = true if Tuttle.automount_engine.nil?

      mount_engine! if Tuttle.automount_engine
      use_profiling_middleware! if Tuttle.enable_profiling

      if Tuttle.track_notifications
        Tuttle::Instrumenter.initialize_tuttle_instrumenter
      end
    end

    config.to_prepare do
      Tuttle::Engine.reload_needed = true
    end

    private

    def mount_engine!
      Rails.application.routes.prepend do
        Tuttle::Engine.logger.info('Auto-mounting /tuttle routes')
        mount Tuttle::Engine, at: 'tuttle'
      end
    end

    def use_profiling_middleware!
      # Add memory/cpu profiler middleware at the end of the stack
      Tuttle::Engine.logger.info('Using Tuttle::Middleware::RequestProfiler middleware')
      require 'tuttle/middleware/request_profiler'
      Rails.application.config.middleware.use Tuttle::Middleware::RequestProfiler
    end

  end
end
