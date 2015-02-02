module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle
    engine_name :tuttle

    config.tuttle = ActiveSupport::OrderedOptions.new

    attr_accessor :reload_needed
    attr_accessor :events, :event_counts, :cache_events
    attr_accessor :session_start, :session_id

    attr_reader :logger

    initializer :tuttle_assets_precompile do |app|
      app.config.assets.precompile += %w(tuttle/application.css tuttle/application.js )
    end

    initializer :tuttle_set_configuration do |app|
      app.config.tuttle.each do |k,v|
        Tuttle.send("#{k}=", v)
      end
      # Tuttle will be automatically enabled in development if not configured explicitly
      Tuttle.enabled= Rails.env.development? if Tuttle.enabled==nil
      Tuttle.automount_engine= true if Tuttle.automount_engine==nil
    end

    initializer :tuttle_startup do
      next unless Tuttle.enabled

      Tuttle::Engine.session_start = Time.now
      Tuttle::Engine.session_id = SecureRandom.uuid
      @logger = ::Logger.new("#{Rails.root}/log/tuttle.log")
      @logger.info('Tuttle engine started')
    end

    initializer :tuttle_track_reloads, group: :all do
      next unless Tuttle.enabled

      ActionDispatch::Reloader.to_prepare do
        Tuttle::Engine.logger.warn('ActionDispatch::Reloader called to_prepare') unless Tuttle::Engine.reload_needed.nil?
        Tuttle::Engine.reload_needed = true
      end
    end

    initializer :tuttle_global_instrumenter, group: :all do
      next unless Tuttle.enabled

      Tuttle::Engine.events = []
      Tuttle::Engine.event_counts = Hash.new(0)

      # For now, only instrument non-production mode
      unless Rails.env.production?
        ActiveSupport::Notifications.subscribe(/.*/) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          Tuttle::Engine.events << event
          Tuttle::Engine.event_counts[event.name] += 1
        end
      end

      Tuttle::Engine.cache_events = []
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

    initializer :tuttle_automounter do
      next unless Tuttle.enabled

      if Tuttle.automount_engine
        Rails.application.routes.append do
          Tuttle::Engine.logger.info('Auto-mounting /tuttle routes')
          mount Tuttle::Engine, at: "tuttle"
        end
      end
    end

  end
end
