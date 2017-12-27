lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tuttle/version'

Gem::Specification.new do |s|
  s.name        = 'tuttle'
  s.version     = Tuttle::VERSION
  s.authors     = ['Dave Gynn']
  s.email       = ['davegynn@gmail.com']
  s.homepage    = 'https://github.com/dgynn/tuttle'
  s.summary     = 'Tuttle for Rails'
  s.description = 'Rails server inspector'
  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*'] + %w[MIT-LICENSE Rakefile README.md CHANGELOG.md]

  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'rails', '>= 4.1.0'

  s.add_development_dependency 'appraisal', '>= 2.2.0'
end
