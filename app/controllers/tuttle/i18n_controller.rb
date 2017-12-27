require_dependency 'tuttle/application_controller'

module Tuttle
  class I18nController < ApplicationController

    before_action :set_sorted_locales

    def index
    end

    def localize
    end

    def translations
      @translations = I18n.backend.send(:translations)
    end

    private

    def set_sorted_locales
      @sorted_locales = [I18n.default_locale] +
                        (I18n.available_locales.map(&:to_s).sort.map(&:to_sym) - [I18n.default_locale])
    end

  end
end
