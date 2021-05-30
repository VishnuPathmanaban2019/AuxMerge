Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  # home routes
  get 'home', to: 'home#index', as: :home

  # user routes
  get '/auth/spotify/callback', to: 'users#spotify'
  get 'users/:id', to: 'user#show'

  # room routes
  post 'rooms/new', to: 'rooms#new'
  get 'rooms/:id', to: 'rooms#show'

  # root @ home
  root 'home#index'
end
