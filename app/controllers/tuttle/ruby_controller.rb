require_dependency 'tuttle/application_controller'

module Tuttle
  class RubyController < ApplicationController

    def index
      # TODO: need better filter for sensitive values. this covers DB-style URLs with passwords, passwords, and keys
      @filtered_env = ENV.to_hash.tap{ |h| h.each{ |k,_v| h[k] = '--FILTERED--' if /.*_(URL|PASSWORD|KEY|KEY_BASE)$/ =~ k  } }
    end

  end
end
