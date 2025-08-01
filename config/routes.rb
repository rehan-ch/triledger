Rails.application.routes.draw do
  devise_for :users
  
  # ERP System Routes
  resources :employees
  resources :roles
  
  # Finance System Routes
  resources :accounts
  resources :transactions do
    collection do
      get :categories
    end
  end
  
  # Dashboard
  root 'dashboard#index'
  
  # Profile management
  resource :profile, only: [:show, :edit, :update]
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
