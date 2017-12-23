# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'
SimpleCov.start 'rails' do
  add_group 'Presenters', 'lib/tuttle/presenters'
end

if ENV['CODACY_PROJECT_TOKEN']
  require 'codacy-coverage'
  Codacy::Reporter.start
end

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

# Load support files - current there are no support files needed
# Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
end

# rubocop:disable Style/ClassAndModuleChildren
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

require 'devise/version'
class ActionController::TestCase
  if Devise::VERSION < '4.2'
    include Devise::TestHelpers
  else
    include Devise::Test::ControllerHelpers
  end

  setup do
    @routes = Tuttle::Engine.routes
  end
end
# rubocop:enable Style/ClassAndModuleChildren
