module Tuttle
  class Instrumenter

    mattr_accessor :events, :event_counts, :cache_events
    self.events = []
    self.event_counts = Hash.new(0)
    self.cache_events = []

    def self.initialize_tuttle_instrumenter
      # For now, only instrument non-production mode
      unless Rails.env.production?
        ActiveSupport::Notifications.subscribe(/.*/) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          Tuttle::Instrumenter.events << event
          Tuttle::Instrumenter.event_counts[event.name] += 1
        end
      end

      # Note: For Rails < 4.2 instrumentation is not enabled by default. Hitting the cache inspector page will enable it for that session.
      Tuttle::Engine.logger.info('Initializing cache_read subscriber')
      ActiveSupport::Notifications.subscribe('cache_read.active_support') do |*args|
        cache_call_location = caller_locations.detect { |cl| cl.path.start_with?("#{Rails.root}/app".freeze) }
        event = ActiveSupport::Notifications::Event.new(*args)

        Tuttle::Engine.logger.info("Cache Read called: #{cache_call_location.path} on line #{cache_call_location.lineno} :: #{event.payload.inspect}")

        event.payload.merge!(:call_location_path => cache_call_location.path, :call_location_lineno => cache_call_location.lineno)
        Tuttle::Instrumenter.cache_events << event
      end

      ActiveSupport::Notifications.subscribe('cache_generate.active_support') do
        Tuttle::Engine.logger.info('Cache Generate called')
      end
    end

  end
end
