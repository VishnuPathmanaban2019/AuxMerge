Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  # home routes
  get 'home', to: 'home#index', as: :home

  # authorization route
  get '/auth/spotify/callback', to: 'users#spotify'

  resources :users
  resources :rooms

  # root @ home
  root 'home#index'
end
