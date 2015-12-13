Tuttle::Engine.routes.draw do

  root :to => 'home#index'

  namespace :rails do
    get '', :action => :index
    get :controllers, :models, :database, :schema_cache, :helpers, :assets,
        :routes, :instrumentation, :cache, :generators, :engines
  end

  namespace :ruby do
    get '', :action => :index
    get :tuning, :miscellaneous
  end

  namespace :gems do
    get '', :action => :index
    get :http_clients, :json, :other
  end

  namespace :active_support do
    get '', :action => :index
    get :dependencies, :inflectors, :time_zones
  end

  get '/request' => 'request#index'

  if defined?(Paperclip)
    get '/paperclip' => 'paperclip#index'
  end

  if defined?(Devise)
    get '/devise' => 'devise#index'
  end

  if defined?(CanCanCan)
    get '/cancancan' => 'cancancan#index'
    get '/cancancan/rule_tester' => 'cancancan#rule_tester'
  end

end
