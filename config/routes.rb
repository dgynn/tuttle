Tuttle::Engine.routes.draw do

  get '/rails' => 'rails#index'
  get '/ruby' => 'ruby#index'

  root :to => 'home#index'

end
