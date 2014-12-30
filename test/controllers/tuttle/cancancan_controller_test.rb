require 'test_helper'

module Tuttle
  class CancancanControllerTest < ActionController::TestCase

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
      assert_nil assigns(:subject)
    end

    test 'should get rule_tester with subject' do
      get :rule_tester, { :action_name => 'manage', :subject_class => 'User' }

      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
      assert_not_nil assigns(:subject)
    end

    test 'should get rule_tester with subject and subject_id' do
      get :rule_tester, { :action_name => 'manage', :subject_class => 'User', :subject_id => 1 }

      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
      assert_not_nil assigns(:subject)
    end

    test 'should get rule_tester with invalid subject' do

      get :rule_tester, { :action_name => 'manage', :subject_class => 'ClassDoesNotExist' }

      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
      assert_nil assigns(:subject)
    end

  end

end
