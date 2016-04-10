require 'test_helper'

class ProfilingMiddlewareTest < ActionDispatch::IntegrationTest

  test "memory profiling middleware" do
    get "/tuttle/gems/other?tuttle-profiler=memory_profiler"
    assert response.body.start_with?('Report from Tuttle::Middeware::RequestProfiler')
    assert_response :success
  end

  test "cpu profiling middleware" do
    get "/tuttle/gems/other?tuttle-profiler=ruby-prof"
    assert_select 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test "cpu profiling middleware with fast stack" do
    get "/tuttle/gems/other?tuttle-profiler=ruby-prof&ruby-prof_printer=fast_stack"
    assert_select 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test "cpu profiling middleware with flat report" do
    get "/tuttle/gems/other?tuttle-profiler=ruby-prof&ruby-prof_printer=flat"
    assert response.body.start_with?('Measure Mode: wall_time')
    assert_response :success
  end

  test "cpu profiling middleware with graph reprot" do
    get "/tuttle/gems/other?tuttle-profiler=ruby-prof&ruby-prof_printer=graph"
    assert_select 'h1', 'Profile Report: wall_time'
    assert_response :success
  end

end
