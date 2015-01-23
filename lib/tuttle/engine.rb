module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    attr_accessor :reload_needed
    attr_accessor :events, :event_counts, :cache_events
    attr_accessor :session_start, :session_id

    attr_reader :logger

    initializer :tuttle_startup do
      Tuttle::Engine.session_start = Time.now
      Tuttle::Engine.session_id = SecureRandom.uuid
      @logger = ::Logger.new("#{Rails.root}/log/tuttle.log")
      @logger.info('Tuttle engine started')
    end

    initializer :tuttle_assets_precompile do |app|
      app.config.assets.precompile += %w(tuttle/application.css tuttle/application.js )
    end

    initializer :tuttle_track_reloads, group: :all do
      ActionDispatch::Reloader.to_prepare do
        Tuttle::Engine.logger.warn('ActionDispatch::Reloader called to_prepare') unless Tuttle::Engine.reload_needed.nil?
        Tuttle::Engine.reload_needed = true
      end
    end

    initializer :tuttle_global_instrumenter, group: :all do
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
      ActiveSupport::Notifications.subscribe('cache_read.active_support') do |*args|
        cache_call_location = caller_locations.detect { |cl| cl.path.start_with?("#{Rails.root}/app".freeze) }
        event = ActiveSupport::Notifications::Event.new(*args)

        Tuttle::Engine.logger.info("Cache Read called: #{cache_call_location.path} on line #{cache_call_location.lineno} :: #{event.payload.inspect}")

        event.payload.merge!({:call_location_path => cache_call_location.path, :call_location_lineno => cache_call_location.lineno })
        Tuttle::Engine.cache_events << event
      end
    end

    initializer :tuttle_automounter do
      if Tuttle.automount_engine
        Rails.application.routes.append do
          mount Tuttle::Engine, at: "tuttle"
        end
      end
    end

  end
end
