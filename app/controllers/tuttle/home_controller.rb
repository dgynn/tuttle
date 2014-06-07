require_dependency "tuttle/application_controller"

module Tuttle
  class HomeController < ApplicationController

    def index
      @apps = ObjectSpace.each_object(::Class).select {|klass| klass < Rails::Application }
      @config = @apps[0].config
    end
  end

end
