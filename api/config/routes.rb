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

      # Inventory management
      resources :inventories, except: [:new, :edit] do
        # This creates all CRUD routes: index, show, create, update, destroy
      end
      
      # User inventory settings - single resource per user
      get '/inventory-settings', to: 'user_inventory_settings#show'
      post '/inventory-settings', to: 'user_inventory_settings#create'
      patch '/inventory-settings', to: 'user_inventory_settings#update'
      put '/inventory-settings', to: 'user_inventory_settings#update'

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

  # Admin routes
  namespace :admin do
    # Spider management
    resources :spiders, only: [:index], param: :name do
      post :run, on: :member
    end
  end
end
