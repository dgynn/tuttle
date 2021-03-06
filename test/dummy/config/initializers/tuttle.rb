# Test with setting an application-level config
Rails.application.config.tuttle.enabled = true

# Test with setting properties directly
Tuttle.setup do |config|
  config.automount_engine = true
  config.track_notifications = true
end

require 'tuttle/middleware/request_profiler'
Rails.application.config.middleware.use Tuttle::Middleware::RequestProfiler
