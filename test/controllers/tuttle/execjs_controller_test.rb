require 'test_helper'

module Tuttle
  class ExecjsControllerTest < ActionController::TestCase

    test 'should get index' do
      get :index
      assert_response :success
    end

  end
end
