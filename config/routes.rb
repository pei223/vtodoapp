Rails.application.routes.draw do
  #devise_for :users

  devise_for :users, :controllers => {
    :sessions       => "users/sessions",
    :registrations  => "users/registrations",
    :passwords      => "users/passwords",
    #:omniauth_callbacks => "users/omniauth_callbacks"
  }
  devise_scope :user do
    get "users/is_signed_in" => "users/sessions#is_signed_in"
    get "users/data" => "users/registrations#data"
  end

  #resources :todos
  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, format: 'json' do
   resources :todos, only: [:index, :create, :update, :destroy]
   post "todos/change_finish/" => "todos#change_finish"
   get "todos/search" => "todos#search"
   get "todos/max_page" => "todos#max_page"
  end
end
