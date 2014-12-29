require 'test_helper'

module Tuttle
  class HomeControllerTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:event_counts)
    end
  end
end
