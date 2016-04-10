require_dependency 'tuttle/application_controller'

module Tuttle
  class ActiveModelSerializersController < ApplicationController

    def index
      @models = ActiveRecord::Base.descendants
      @models.sort_by!(&:name)

      @serializers = ::ActiveModel::Serializer.descendants
      @serializers.sort_by!(&:name)

      @adapter_map = if ActiveModel::Serializer::Adapter.const_defined?(:ADAPTER_MAP)
                       ActiveModel::Serializer::Adapter.const_get(:ADAPTER_MAP)
                     else
                       ActiveModelSerializers::Adapter.const_get(:ADAPTER_MAP)
                     end

      unless defined?(ActiveModelSerializers)
        render 'index9'
      end

    end

  end
end
