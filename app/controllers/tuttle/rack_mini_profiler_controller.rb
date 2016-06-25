require_dependency 'tuttle/application_controller'

module Tuttle
  class RackMiniProfilerController < ApplicationController

    def index
      return redirect_to gems_other_path unless defined?(::Rack::MiniProfiler::Config)

      require_dependency 'tuttle/presenters/rack_mini_profiler/client_settings'
      @mp_config = ::Rack::MiniProfiler.config
      @mp_client_settings = Tuttle::Presenters::RackMiniProfiler::ClientSettings.new(request.env)
    end

  end
end
