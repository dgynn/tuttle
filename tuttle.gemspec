$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'tuttle/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'tuttle'
  s.version     = Tuttle::VERSION
  s.authors     = ['Dave Gynn']
  s.email       = ['davegynn@gmail.com']
  s.homepage    = 'https://github.com/dgynn/tuttle'
  s.summary     = 'Tuttle for Rails'
  s.description = 'Rails server inspector'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 4.1.8'
  # Temporarily make dev dependencies runtime dependencies for testing
  s.add_dependency 'byebug'
  s.add_dependency 'devise'
  s.add_dependency 'cancancan'
  # s.add_development_dependency 'byebug'
  # s.add_development_dependency 'devise'
  # s.add_development_dependency 'cancancan'
  s.add_development_dependency 'rake'

end
