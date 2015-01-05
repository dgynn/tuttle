require_dependency 'tuttle/application_controller'

# NOTE: needed for ruby < 2.1.5 - should figure out why
require 'tuttle/version'

module Tuttle
  class HomeController < ApplicationController

    def index
      @event_counts = Tuttle::Engine.event_counts
    end

  end
end
