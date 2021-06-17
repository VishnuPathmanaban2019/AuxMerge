Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  # home routes
  get 'home', to: 'home#index', as: :home

  # authorization route
  get '/auth/spotify/callback', to: 'users#spotify'

  resources :users
  get 'users/:id/logout', to: 'users#logout', as: :logout
  get 'users/:id/join_room', to: 'users#join_room', as: :join_room
  post 'users/:id/join_room', to: 'users#join_room', as: :joined_room
  
  resources :rooms
  get 'rooms/:id/playlist', to: 'rooms#playlist', as: :room_playlist

  post 'user_room_relations', to: 'user_room_relations#create', as: :user_room_relations
  get 'user_room_relations/new', to: 'user_room_relations#new', as: :new_user_room_relation

  # root @ home
  root 'home#index'
end
