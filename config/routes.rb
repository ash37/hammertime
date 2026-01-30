Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "/dashboard", to: "dashboard#show"

  resources :jobs do
    post :add_timesheets_to_invoice, on: :member
    post :add_materials_to_invoice, on: :member
  end

  resources :timesheet_entries, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    collection do
      get :draft_payroll_preview
      post :draft_payroll
    end
    member do
      patch :approve
    end
  end
  resources :material_purchases, only: [ :index, :show, :new, :create, :edit, :update ]

  resources :invoices, only: [ :index, :show, :new, :create, :edit, :update ] do
    member do
      get :print
      post :add_labour
      post :add_materials
      patch :mark_sent
      patch :mark_paid
      patch :void
    end
  end

  resources :customers do
    member do
      patch :archive
      patch :restore
    end
  end

  resources :users do
    member do
      post :invite
      patch :deactivate
      patch :roster, action: :update_roster
    end
  end

  namespace :settings do
    resource :company, only: [ :edit, :update ], controller: "company_details"
  end
end
