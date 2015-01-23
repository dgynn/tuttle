module Tuttle
  class ApplicationController < ActionController::Base
    abstract!

    before_action :check_reload_status

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
