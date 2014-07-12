module Tuttle
  class Engine < ::Rails::Engine
    isolate_namespace Tuttle

    attr_accessor :reload_needed
    attr_accessor :events, :event_counts

    initializer "tuttle.assets.precompile" do |app|
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

      ActiveSupport::Notifications.subscribe(/.*/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Tuttle::Engine.events << event
        Tuttle::Engine.event_counts[event.name]+=1
      end
    end

  end

end
