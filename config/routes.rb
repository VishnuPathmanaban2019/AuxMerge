Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  # home routes
  get 'home', to: 'home#index', as: :home
  get 'home/result', to: 'home#result', as: :result

  # authorization route
  get '/auth/spotify/callback', to: 'users#spotify'

  resources :users
  resources :rooms

  post 'user_room_relations', to: 'user_room_relations#create', as: :user_room_relations
  get 'user_room_relations/new', to: 'user_room_relations#new', as: :new_user_room_relation

  # root @ home
  root 'home#index'
end
