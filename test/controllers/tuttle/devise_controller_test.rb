require 'test_helper'

module Tuttle
  class DeviseControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

  end
end
