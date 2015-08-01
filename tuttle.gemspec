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

  s.files = Dir['{app,config,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md', 'CHANGELOG.md']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'rails', '>= 4.0.0', '< 5.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'appraisal'

end
