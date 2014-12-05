require_dependency 'tuttle/application_controller'

module Tuttle
  class HomeController < ApplicationController

    def index
      @event_counts = Tuttle::Engine.event_counts
    end

  end
end
