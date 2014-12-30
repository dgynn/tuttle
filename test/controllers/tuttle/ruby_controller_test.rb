require 'test_helper'

module Tuttle
  class RubyControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

  end
end
