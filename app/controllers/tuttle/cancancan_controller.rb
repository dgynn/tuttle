require_dependency "tuttle/application_controller"

module Tuttle
  class CancancanController < ApplicationController

    def index
      @cancan_user = current_user || User.new
      @ability = Ability.new(@cancan_user)
    end

  end
end
