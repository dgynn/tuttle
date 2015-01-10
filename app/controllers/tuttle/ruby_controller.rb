require_dependency 'tuttle/application_controller'

module Tuttle
  class RubyController < ApplicationController

    def index
      # TODO: need better filter for sensitive values. this covers DB-style URLs with passwords.
      @filtered_env = ENV.to_hash.tap{ |h| h.each{ |k,_v| h[k] = '--FILTERED--' if /.*_URL$/ =~ k  } }
    end

  end
end
