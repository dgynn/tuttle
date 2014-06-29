Tuttle::Engine.routes.draw do

  get '/rails' => 'rails#index'
  get '/rails/controllers' => 'rails#controllers'
  get '/rails/models' => 'rails#models'

  get '/ruby' => 'ruby#index'

  root :to => 'home#index'

end
