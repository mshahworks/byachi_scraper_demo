Rails.application.routes.draw do
  root 'events#index'
  resources :events, except: [:new, :create, :edit, :update]
end