require_dependency 'tuttle/application_controller'

module Tuttle
  class PerformanceTuningController < ApplicationController

    def index
      if defined?(::Rack::MiniProfiler)
        @mp_config = ::Rack::MiniProfiler.config
        @mp_client_settings = ::Rack::MiniProfiler::ClientSettings.new(request.env)
      end
    end

  end
end
