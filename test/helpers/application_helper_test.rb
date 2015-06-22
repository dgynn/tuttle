require 'test_helper'

module Tuttle
  class ActionHelperTest < ActiveSupport::TestCase

    include Tuttle::ApplicationHelper

    test 'tuttle_redacted should redact passwords' do
      test_hash = { 'password' => 'PASSWORD', 'key1' => 'VALUE1' }
      test_results = tuttle_redacted(test_hash.each) { |key, value| [key, value] }.to_h
      assert_equal '--HIDDEN--', test_results['password']
      assert_equal test_hash['key1'], test_results['key1']
    end

  end

end
