require 'test_helper'

class ProfilingMiddlewareTest < ActionDispatch::IntegrationTest

  # This temporarily sets verbosity to nil to deal with overly-strict HTML parsing
  def assert_select_quietly(*args)
    verbosity = $-v
    $-v = nil
    assert_select(*args)
    $-v = verbosity
  end

  test 'no middleware' do
    get '/tuttle'
    assert_select 'h1', 'Tuttle Dashboard'
    assert_response :success
  end

  test 'memory profiling middleware' do
    get '/tuttle?tuttle-profiler=memory_profiler'
    assert response.body.start_with?('Report from Tuttle::Middeware::RequestProfiler')
    assert_response :success
  end

  test 'cpu profiling middleware' do
    get '/tuttle?tuttle-profiler=ruby-prof'
    assert_select_quietly 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test 'cpu profiling middleware with fast stack' do
    get '/tuttle?tuttle-profiler=ruby-prof&ruby-prof_printer=fast_stack'
    assert_select_quietly 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test 'cpu profiling middleware with stack report' do
    get '/tuttle?tuttle-profiler=ruby-prof&ruby-prof_printer=stack'
    assert_select_quietly 'title', 'ruby-prof call tree'
    assert_response :success
  end

  test 'cpu profiling middleware with flat report' do
    get '/tuttle?tuttle-profiler=ruby-prof&ruby-prof_printer=flat'
    assert response.body.start_with?('Measure Mode: wall_time')
    assert_response :success
  end

  test 'cpu profiling middleware with graph report' do
    get '/tuttle?tuttle-profiler=ruby-prof&ruby-prof_printer=graph'
    assert_select_quietly 'h1', 'Wall_time'
    assert_response :success
  end

  test 'busted profiling middleware' do
    skip # Need to document how to enable dtrace
    skip unless defined?(::Busted) && Busted::Tracer.exists?
    get '/tuttle?tuttle-profiler=busted'
    assert response.body.include? 'Caches Request Observer'
    assert_response :success
  end

end
