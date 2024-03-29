# frozen_string_literal: true
require_dependency 'tuttle/application_controller'

module Tuttle
  class RackAttackController < ApplicationController

    def index
      require 'rack/attack/version'
      if ::Rack::Attack::VERSION < '6'
        render plain: 'Tuttle Rack::Attack support requires version 6.x' && return
      end

      default_keys = %w[rack.attack.matched rack.attack.match_discriminator rack.attack.match_type rack.attack.match_data]
      rack_attack_env_vars = request.env.select { |k, _v| k.to_s.start_with?('rack.attack') }
      @rack_attack_env_settings = (rack_attack_env_vars.keys + default_keys).uniq

      @throttles = Rack::Attack.throttles
      @safelists = Rack::Attack.safelists
      @blocklists = Rack::Attack.blocklists
      # TODO: tracks are no longer exposed
      # @tracks = Rack::Attack.tracks
      @tracks = []

      @asn_listeners = ActiveSupport::Notifications.notifier.listeners_for("rack.attack")
    end

  end
end
