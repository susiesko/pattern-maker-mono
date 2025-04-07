Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Handle favicon requests to prevent 404 errors in logs
  get '/favicon.ico', to: proc { [204, {}, ['']] }

  # API routes with versioning
  namespace :api do
    namespace :v1 do
      # Status endpoint for health checks
      resources :status, only: [:index]

      # Authentication routes
      post '/auth/login', to: 'authentication#login'
      post '/auth/register', to: 'users#create'
      get '/auth/me', to: 'authentication#me'

      # User management
      resources :users

      # Password management
      put '/password', to: 'passwords#update'

      # Catalog namespace for all bead-related resources
      namespace :catalog do
        # Main bead resources
        resources :beads

        # Supporting resources
        resources :bead_brands
        resources :bead_types
        resources :bead_sizes
        resources :bead_colors
        resources :bead_finishes
      end
    end
  end
end
