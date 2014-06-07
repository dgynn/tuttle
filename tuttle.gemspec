$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tuttle/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tuttle"
  s.version     = Tuttle::VERSION
  s.authors     = ['Dave Gynn']
  s.email       = ['dgynn@yahoo.com']
  s.homepage    = "http://www.gynn.org/"
  s.summary     = "Tuttle for Rails"
  s.description = "Rails server inspector"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2.18"
  s.add_development_dependency 'byebug'

end
