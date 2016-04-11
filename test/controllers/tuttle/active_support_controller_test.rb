require 'test_helper'

module Tuttle
  class ActiveSupportControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

    test 'should get dependencies' do
      get :dependencies
      assert_response :success
    end

    test 'should get time_zones' do
      get :time_zones
      assert_response :success
    end

    test 'should get inflectors' do
      get :inflectors
      assert_response :success
      assert_not_nil assigns(:test_word)
      assert_not_nil assigns(:plurals)
    end

  end
end
