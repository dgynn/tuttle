require_dependency 'tuttle/application_controller'

module Tuttle
  class I18nController < ApplicationController

    def index
    end

    def localize
    end

    def translations
      @translations = I18n.backend.send(:translations)
    end

  end
end
