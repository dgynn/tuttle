require 'test_helper'

module Tuttle
  class HomeControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
      assert_select 'h1', 'Tuttle Dashboard'
    end

  end
end
