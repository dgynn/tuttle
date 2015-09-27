require 'rails'
require 'rails/engine'

module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle
    engine_name :tuttle

    config.tuttle = ActiveSupport::OrderedOptions.new

    mattr_accessor :reload_needed
    mattr_accessor :events, :event_counts, :cache_events
    @@events = []
    @@event_counts = Hash.new(0)
    @@cache_events = []

    mattr_accessor :session_start, :session_id

    mattr_reader :logger

    initializer 'tuttle' do |app|

      app.config.tuttle.each do |k, v|
        Tuttle.send("#{k}=", v)
      end

      # Tuttle will be automatically enabled in development if not configured explicitly
      Tuttle.enabled = Rails.env.development? if Tuttle.enabled==nil

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

      initialize_tuttle_instrumenter if Tuttle.track_notifications

    end

    private

    def initialize_tuttle_instrumenter

      # For now, only instrument non-production mode
      unless Rails.env.production?
        ActiveSupport::Notifications.subscribe(/.*/) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          Tuttle::Engine.events << event
          Tuttle::Engine.event_counts[event.name] += 1
        end
      end

      # Note: For Rails < 4.2 instrumentation is not enabled by default. Hitting the cache inspector page will enable it for that session.
      Tuttle::Engine.logger.info('Initializing cache_read subscriber')
      ActiveSupport::Notifications.subscribe('cache_read.active_support') do |*args|
        cache_call_location = caller_locations.detect { |cl| cl.path.start_with?("#{Rails.root}/app".freeze) }
        event = ActiveSupport::Notifications::Event.new(*args)

        Tuttle::Engine.logger.info("Cache Read called: #{cache_call_location.path} on line #{cache_call_location.lineno} :: #{event.payload.inspect}")

        event.payload.merge!({:call_location_path => cache_call_location.path, :call_location_lineno => cache_call_location.lineno })
        Tuttle::Engine.cache_events << event
      end
      ActiveSupport::Notifications.subscribe('cache_generate.active_support') do |*args|
        Tuttle::Engine.logger.info('Cache Generate called')
      end

    end

  end
end
