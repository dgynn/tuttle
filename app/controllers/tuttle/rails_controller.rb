require_dependency "tuttle/application_controller"

module Tuttle
  class RailsController < ApplicationController

    def index
      @config = Rails.configuration
    end

    def controllers
      # TODO: Both ObjectSpace and .descendants approaches have issues with class reloading during development
      # It seems likely that .descendants will work best when Tuttle and Rails classes are not modified
      # but both approaches also require eager_load to be true
      # @controllers = ObjectSpace.each_object(::Class).select {|klass| klass < ActionController::Base }
      @controllers = ActionController::Base.descendants
      @controllers.reject! {|controller| controller <= Tuttle::ApplicationController || controller.abstract?}
    end

    def models
      @models = ActiveRecord::Base.descendants
    end
  end
end
