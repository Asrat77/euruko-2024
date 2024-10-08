Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :users, only: %i[ show new create ]
  resources :sessions, only: %i[ new create ]

  constraints(AuthenticatedConstraint.new) do
    resources :users, only: %i[ edit update destroy ]
    resources :sessions, only: %i[ destroy ]
    resources :posts, only: %i[ new create edit update destroy ] do
      resources :comments, only: %i[ create edit update destroy ], shallow: true
    end
  end

  resources :posts, only: %i[ index show ]

  namespace :benchmarking do
    post "post_create"
    post "comment_create"
    post "post_destroy"
    post "comment_destroy"
    post "post_show"
    post "posts_index"
    post "user_show"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "posts#index"
end
