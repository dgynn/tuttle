require_dependency 'tuttle/application_controller'
require 'devise/version' if defined? Devise

module Tuttle
  class DeviseController < ApplicationController

    def index
      render(plain: "Devise not installed") and return unless defined? ::Devise
    end

  end
end
