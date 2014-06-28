require_dependency "tuttle/application_controller"

module Tuttle
  class RailsController < ApplicationController

    def index
      @config = Rails.configuration
    end

  end
end
