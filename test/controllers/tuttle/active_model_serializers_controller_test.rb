require 'test_helper'

module Tuttle
  class ActiveModelSerializersControllerTest < ActionController::TestCase

    test 'should get index' do
      skip unless defined?(::ActiveModel::Serializer)
      get :index
      assert_response :success
    end

  end
end
