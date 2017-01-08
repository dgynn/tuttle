module Tuttle
  class ApplicationController < ActionController::Base
    abstract!
    protect_from_forgery with: :exception

    before_action :check_reload_status

    private

    def check_reload_status
      return unless Tuttle::Engine.reload_needed && !Rails.configuration.eager_load
      Tuttle::Engine.logger.warn('Eager-loading application')
      ActiveSupport::Notifications.instrument 'tuttle.perform_eager_load' do
        Rails.application.eager_load!
        Tuttle::Engine.reload_needed = false
      end
    end

  end
end
