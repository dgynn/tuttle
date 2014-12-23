Tuttle::Engine.routes.draw do

  root :to => 'home#index'

  namespace :rails do
    get '', :action => :index
    get :controllers, :models, :database, :helpers, :assets, :routes, :instrumentation
  end

  get '/ruby' => 'ruby#index'

  get '/devise' => 'devise#index'

  get '/cancancan' => 'cancancan#index'
  get '/cancancan/rule_tester' => 'cancancan#rule_tester'

end
