require_dependency 'tuttle/application_controller'
require 'tuttle/version'

module Tuttle
  class HomeController < ApplicationController

    def index
      @event_counts = Tuttle::Instrumenter.event_counts
    end

  end
end
