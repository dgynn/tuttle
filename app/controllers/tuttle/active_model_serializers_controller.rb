require_dependency 'tuttle/application_controller'

module Tuttle
  class ActiveModelSerializersController < ApplicationController

    def index
      @models = ActiveRecord::Base.descendants
      @models.sort_by!(&:name)

      @serializers = ::ActiveModel::Serializer.descendants
      @serializers.sort_by!(&:name)

      unless defined?(ActiveModelSerializers)
        render 'index9'
      end

    end

  end
end