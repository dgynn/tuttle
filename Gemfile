source 'https://rubygems.org'

# Declare your gem's dependencies in tuttle.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development, :test do
  # jquery-rails is used by the dummy application
  gem 'jquery-rails'

  gem 'sqlite3'

  gem 'cancancan'

  # To use debugger
  # gem 'debugger'

  gem 'codeclimate-test-reporter', require: nil

  gem 'memory_profiler'

  # This fork of ruby-prof is required for the middleware tests only
  gem 'ruby-prof', :github => 'dgynn/ruby-prof', :branch => 'performance_tuning_experiments'

end
