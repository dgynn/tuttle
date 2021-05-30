lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tuttle/version'

Gem::Specification.new do |s|
  s.name        = 'tuttle'
  s.version     = Tuttle::VERSION
  s.authors     = ['Dave Gynn']
  s.email       = ['davegynn@gmail.com']
  s.homepage    = 'https://github.com/dgynn/tuttle'
  s.summary     = 'Rails runtime configuration inspector'
  s.description = 'Tuttle is a tool for Rails developers to inspect the runtime configuration information of their applications, libraries, and frameworks.'

  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*'] + %w[MIT-LICENSE Rakefile README.md CHANGELOG.md]

  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency 'rails', '>= 5.2.0'

  s.add_development_dependency 'appraisal', '>= 2.4.0'
end
