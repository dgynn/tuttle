require 'test_helper'

module Tuttle
  class RailsControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success

      assert_select "#config tr[data-config-key=enable_dependency_loading]", 1
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
      assert_not_nil assigns(:data_sources)
    end

    test 'should get schema_cache' do
      get :schema_cache
      assert_response :success
      assert_not_nil assigns(:schema_cache_filename)
      assert_not_nil assigns(:schema_cache)
      assert_not_nil assigns(:connection_schema_cache)
    end

    test 'should get engines' do
      get :engines
      assert_response :success
      assert_not_nil assigns(:engines)
    end

    test 'should get generators' do
      get :generators
      assert_response :success
      assert_not_nil assigns(:generators)
    end

    test 'should get helpers' do
      get :helpers
      assert_response :success
      assert_not_nil assigns(:helpers)
    end

    test 'should get assets' do
      get :assets
      assert_response :success
      assert_not_nil assigns(:sprockets_env)
      assert_not_nil assigns(:assets_config)
    end

    test 'should get routes' do
      get :routes
      assert_response :success
      assert_not_nil assigns(:routes)
    end

    test 'should get instrumentation' do
      skip "This is hanging sometimes"
      get :instrumentation
      assert_response :success
      assert_not_nil assigns(:events)
      assert_not_nil assigns(:event_counts)
    end

    test 'should get cache' do
      get :cache
      assert_response :success
      assert_not_nil assigns(:cache)
    end

  end
end
