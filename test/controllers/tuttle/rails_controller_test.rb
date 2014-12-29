require 'test_helper'

module Tuttle
  class RailsControllerTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
    end

    test 'should get index' do
      get :index
      assert_response :success
    end

    test 'should get controllers' do
      get :controllers
      assert_response :success
      assert_not_nil assigns(:controllers)
    end

    test 'should get models' do
      get :models
      assert_response :success
      assert_not_nil assigns(:models)
    end

    test 'should get database' do
      get :database
      assert_response :success
      assert_not_nil assigns(:conn)
    end

    test 'should get helpers' do
      get :helpers
      assert_response :success
      assert_not_nil assigns(:helpers)
    end

    test 'should get assets' do
      get :assets
      assert_response :success
      assert_not_nil assigns(:sprockets)
      assert_not_nil assigns(:engines)
    end

    test 'should get routes' do
      get :routes
      assert_response :success
      assert_not_nil assigns(:routes)
    end

    test 'should get instrumentation' do
      get :instrumentation
      assert_response :success
      assert_not_nil assigns(:events)
      assert_not_nil assigns(:event_counts)
    end
  end

end