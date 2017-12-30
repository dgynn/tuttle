# frozen_string_literal: true
module Tuttle
  module Presenters
    module RackMiniProfiler
      class ClientSettings < SimpleDelegator

        def initialize(env)
          rmp_cs_args = [env]
          rmp_cs_args += [::Rack::MiniProfiler.config.storage_instance, Time.current] if version_10?
          super(::Rack::MiniProfiler::ClientSettings.new(*rmp_cs_args))
        end

        def version_10?
          Rack::MiniProfiler::ClientSettings.instance_method(:initialize).arity > 1
        end

        def tuttle_check_cookie
          version_10? ? has_valid_cookie? : has_cookie?
        end

        def tuttle_check_cookie_method
          version_10? ? 'has_valid_cookie?' : 'has_cookie?'
        end

      end
    end
  end
end
