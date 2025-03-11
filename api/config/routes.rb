# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # API routes
  namespace :api do
    namespace :v1 do
      # Main resources
      resources :beads, only: [:index, :show]

      # Additional catalog resources
      # resources :bead_brands, only: [:index, :show], path: 'brands'
      # resources :bead_types, only: [:index, :show], path: 'types'
      # resources :bead_sizes, only: [:index, :show], path: 'sizes'
      # resources :bead_colors, only: [:index, :show], path: 'colors'
      # resources :bead_finishes, only: [:index, :show], path: 'finishes'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
