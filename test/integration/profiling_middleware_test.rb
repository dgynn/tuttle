require 'test_helper'

class ProfilingMiddlewareTest < ActionDispatch::IntegrationTest

  test "memory profiling middleware" do
    get "/tuttle/gems/other?mp=profile-memory"
    assert response.body.start_with?('Report from Tuttle::Middeware::RequestProfiler')
    assert_response :success
  end

  test "cpu profiling middleware" do
    get "/tuttle/gems/other?mp=profile-cpu"
    assert_select 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test "cpu profiling middleware with fast stack" do
    get "/tuttle/gems/other?mp=profile-cpu&mp_printer=fast_stack"
    assert_select 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test "cpu profiling middleware with flat report" do
    get "/tuttle/gems/other?mp=profile-cpu&mp_printer=flat"
    assert response.body.start_with?('Measure Mode: wall_time')
    assert_response :success
  end

  test "cpu profiling middleware with graph reprot" do
    get "/tuttle/gems/other?mp=profile-cpu&mp_printer=graph"
    assert_select 'h1', 'Profile Report: wall_time'
    assert_response :success
  end

end
