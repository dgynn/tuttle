require_dependency "tuttle/application_controller"

module Tuttle
  class CancancanController < ApplicationController

    def index
      @cancan_user = current_user || User.new
      @ability = Ability.new(@cancan_user)
    end

    def rule_tester
      @action = params[:action_name] || 'read'
      subject_class = params[:subject_class]
      subject_id = params[:subject_id]
      if subject_class
        begin
          subject_klass = subject_class.constantize
          @subject = subject_klass.find(subject_id) unless subject_id.blank?
          @subject ||= subject_klass.new
        rescue
          # Could not load subject
        end
      end
      @cancan_user = current_user || User.new
      @ability = Ability.new(@cancan_user)
    end

  end
end
