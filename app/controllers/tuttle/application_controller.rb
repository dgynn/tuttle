# frozen_string_literal: true
module Tuttle
  class ApplicationController < ActionController::Base
    abstract!
    protect_from_forgery with: :exception

    before_action :check_reload_status
    around_action :set_locale

    private

    def check_reload_status
      return unless Tuttle::Engine.reload_needed && !Rails.configuration.eager_load
      Tuttle::Engine.logger.warn('Eager-loading application')
      ActiveSupport::Notifications.instrument 'tuttle.perform_eager_load' do
        Rails.application.eager_load!
        Tuttle::Engine.reload_needed = false
      end
    end

    def set_locale
      if params[:hl] && I18n.locale_available?(params[:hl])
        I18n.with_locale(params[:hl]) do
          yield
        end
      else
        yield
      end
    end

  end
end
