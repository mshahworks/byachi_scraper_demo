Rails.application.routes.draw do
  root 'events#index'
  resources :events, except: [:new, :create, :edit, :update] do 
    collection do 
      get 'future_events'
      get 'past_events'
    end
  end
end