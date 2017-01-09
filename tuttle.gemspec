require './lib/tuttle/version'

Gem::Specification.new do |s|
  s.name        = 'tuttle'
  s.version     = Tuttle::VERSION
  s.authors     = ['Dave Gynn']
  s.email       = ['davegynn@gmail.com']
  s.homepage    = 'https://github.com/dgynn/tuttle'
  s.summary     = 'Tuttle for Rails'
  s.description = 'Rails server inspector'
  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md', 'CHANGELOG.md']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'rails', '>= 4.0.0', '< 5.1'

  s.add_development_dependency 'appraisal', '~> 0'
end
