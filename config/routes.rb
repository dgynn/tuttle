Tuttle::Engine.routes.draw do

  get '/rails' => 'rails#index'
  get '/rails/controllers' => 'rails#controllers'
  get '/rails/models' => 'rails#models'
  get '/rails/helpers' => 'rails#helpers'
  get '/rails/database' => 'rails#database'
  get '/rails/instrumentation' => 'rails#instrumentation'

  get '/ruby' => 'ruby#index'

  get '/devise' => 'devise#index'

  get '/cancancan' => 'cancancan#index'
  get '/cancancan/rule_tester' => 'cancancan#rule_tester'

  root :to => 'home#index'

end
