Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  # home routes
  get 'home', to: 'home#index', as: :home

  get '/auth/spotify/callback', to: 'home#spotify'

  # root @ home
  root 'home#index'
end
