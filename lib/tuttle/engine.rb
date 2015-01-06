module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    attr_accessor :reload_needed
    attr_accessor :events, :event_counts
    attr_accessor :session_start, :session_id

    initializer :tuttle_startup do
      Tuttle::Engine.session_start = Time.now
      Tuttle::Engine.session_id = SecureRandom.uuid
    end

    initializer :tuttle_assets_precompile do |app|
      app.config.assets.precompile += %w(tuttle/application.css tuttle/application.js )
    end

    initializer :tuttle_track_reloads, group: :all do
      ActionDispatch::Reloader.to_prepare do
        Rails.logger.warn('Tuttle: ActionDispatch::Reloader called to_prepare')
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

    end
  end
end
