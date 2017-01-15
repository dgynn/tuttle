require 'test_helper'

module Tuttle
  class I18nControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success

      assert_select 'h1', 'Internationalization'
    end

    test 'should get localize' do
      get :localize
      assert_response :success

      assert_select 'h1', 'Localization'
    end

  end
end
