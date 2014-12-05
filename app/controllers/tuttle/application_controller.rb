module Tuttle
  class ApplicationController < ActionController::Base
    abstract!

    before_action :check_reload_status

    def check_reload_status
      return unless Tuttle::Engine.reload_needed && !Rails.configuration.eager_load
      Rails.logger.warn('Tuttle: Eager-loading application')
      # Rails::Application::Finisher defines an initializer that *would* execute
      #   these two lines if eager_load were enabled
      # ActiveSupport.run_load_hooks(:before_eager_load, Rails.application)
      ActiveSupport::Notifications.instrument 'tuttle.perform_eager_load' do
        Rails.configuration.eager_load_namespaces.each(&:eager_load!)
        Tuttle::Engine.reload_needed = false
      end
    end

  end
end
