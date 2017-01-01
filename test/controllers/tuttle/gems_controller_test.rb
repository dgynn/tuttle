require 'test_helper'

module Tuttle
  class GemsControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

    test 'should get http_clients' do
      get :http_clients
      assert_response :success
    end

    test 'should get json' do
      get :json
      assert_response :success
    end

    test 'should get get_process_mem' do
      get :get_process_mem
      assert_response :success
    end

    test 'should get other' do
      get :other
      assert_response :success
    end

  end
end
