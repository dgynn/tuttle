Tuttle::Engine.routes.draw do

  root :to => 'home#index'

  namespace :rails do
    get '', :action => :index
    get :controllers, :models, :database, :helpers, :assets, :routes, :instrumentation, :inflectors, :cache
  end

  get '/ruby' => 'ruby#index'

  namespace :gems do
    get :http_clients, :json, :other
  end

  if defined?(Devise)
    get '/devise' => 'devise#index'
  end

  if defined?(CanCanCan)
    get '/cancancan' => 'cancancan#index'
    get '/cancancan/rule_tester' => 'cancancan#rule_tester'
  end

end
