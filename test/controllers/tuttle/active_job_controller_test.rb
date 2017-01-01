require 'test_helper'

module Tuttle
  class ActiveJobControllerTest < ActionController::TestCase

    test 'should get index' do
      skip unless defined?(ActiveJob)
      get :index
      assert_response :success
    end

  end
end
