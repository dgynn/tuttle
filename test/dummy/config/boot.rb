require 'rubygems'
gemfile = File.expand_path('../../../../Gemfile', __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] ||= gemfile
end

require 'bundler'
Bundler.setup

$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)
