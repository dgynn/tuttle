Tuttle::Engine.routes.draw do

  get '/rails' => 'rails#index'
  get '/rails/controllers' => 'rails#controllers'
  get '/rails/models' => 'rails#models'
  get '/rails/instrumentation' => 'rails#instrumentation'

  get '/ruby' => 'ruby#index'

  get '/devise' => 'devise#index'

  get '/cancancan' => 'cancancan#index'

  root :to => 'home#index'

end
