require 'test_helper'

module Tuttle
  class RubyControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

    test 'should get tuning' do
      get :tuning
      assert_response :success
    end

    test 'should get miscellaneous' do
      get :miscellaneous
      assert_response :success
    end

    test 'should get extensions' do
      get :extensions
      assert_response :success
    end

    test 'should get constants' do
      get :constants
      assert_response :success
    end

  end
end
