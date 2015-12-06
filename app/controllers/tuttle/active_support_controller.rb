require_dependency 'tuttle/application_controller'

module Tuttle
  class ActiveSupportController < ApplicationController

    def index
    end

    def dependencies
    end

    def inflectors
      @test_word = params[:test_word] || ''

      @plurals = ActiveSupport::Inflector.inflections.plurals
      @singulars = ActiveSupport::Inflector.inflections.singulars
      @uncountables = ActiveSupport::Inflector.inflections.uncountables
      @humans = ActiveSupport::Inflector.inflections.humans
      @acronyms = ActiveSupport::Inflector.inflections.acronyms
    end

    def time_zones
    end

  end
end
