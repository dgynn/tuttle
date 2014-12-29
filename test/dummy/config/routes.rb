Rails.application.routes.draw do

  devise_for :users
  mount Tuttle::Engine => '/tuttle'

end
