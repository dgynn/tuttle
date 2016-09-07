require_dependency 'tuttle/application_controller'

module Tuttle
  class CancancanController < ApplicationController

    def index
      @cancan_user = current_user || User.new
      @ability = Ability.new(@cancan_user)
    end

    def rule_tester
      @models = ActiveRecord::Base.descendants.reject(&:abstract_class)
      @action = params[:action_name] || 'read'
      @subject = find_subject(params[:subject_class], params[:subject_id])
      @cancan_user = current_user || User.new
      @ability = Ability.new(@cancan_user)
    end

    private

    def find_subject(subject_class, subject_id)
      subject_klass = @models.detect { |x| x.name == subject_class } if subject_class.present?
      subject_klass.find_or_initialize_by(:id => subject_id) if subject_klass
    end
  end
end
