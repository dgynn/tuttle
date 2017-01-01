require 'test_helper'

module Tuttle
  class RequestControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

  end
end
