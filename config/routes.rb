Rails.application.routes.draw do
  devise_for :users
  
  # ERP System Routes
  resources :employees
  resources :roles
  
  # Dashboard
  root 'dashboard#index'
  
  # Profile management
  get 'profile', to: 'profiles#show'
  get 'profile/edit', to: 'profiles#edit'
  patch 'profile', to: 'profiles#update'
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
