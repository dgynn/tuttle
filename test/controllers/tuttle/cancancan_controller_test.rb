require 'test_helper'

module Tuttle
  class CancancanControllerTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
    end

    test 'should get index' do
      get :index
      assert_response :success

      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
    end

    test 'should get rule_tester' do
      get :rule_tester
      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
    end
  end

  # TODO: test rule_tester with arguments

end
