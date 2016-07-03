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
      params = { :action_name => 'manage', :subject_class => 'User' }
      if Rails.version < '5'
        get :rule_tester, params
      else
        get :rule_tester, :params => params
      end

      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
      assert_not_nil assigns(:subject)
    end

    test 'should get rule_tester with subject and subject_id' do
      params = { :action_name => 'manage', :subject_class => 'User', :subject_id => 1 }
      if Rails.version < '5'
        get :rule_tester, params
      else
        get :rule_tester, :params => params
      end

      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
      assert_not_nil assigns(:subject)
    end

    test 'should get rule_tester with invalid subject' do
      params = { :action_name => 'manage', :subject_class => 'ClassDoesNotExist' }
      if Rails.version < '5'
        get :rule_tester, params
      else
        get :rule_tester, :params => params
      end

      assert_response :success

      assert_not_nil assigns(:action)
      assert_not_nil assigns(:cancan_user)
      assert_not_nil assigns(:ability)
      assert_nil assigns(:subject)
    end

  end
end
