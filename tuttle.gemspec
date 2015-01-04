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
  s.license       = 'MIT'

  s.files = Dir['{app,config,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 4.1.8'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'appraisal'

end
