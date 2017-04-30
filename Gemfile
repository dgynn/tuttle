source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gemspec

group :development, :test do
  # jquery-rails is used by the dummy application
  gem 'jquery-rails'

  gem 'sqlite3'

  gem 'active_model_serializers'
  gem 'busted'
  gem 'cancancan'
  gem 'devise', '> 3.5.0', github: 'plataformatec/devise'

  gem 'get_process_mem'
  gem 'memory_profiler', :github => 'SamSaffron/memory_profiler', :branch => 'master'
  gem 'paperclip'
  gem 'rack-mini-profiler'
  gem 'ruby-prof'

  gem 'codacy-coverage', require: false
  gem 'codeclimate-test-reporter', require: false
  gem 'rubocop', require: false
end
