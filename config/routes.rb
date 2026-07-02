Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  # Onboarding : choix créer / rejoindre un foyer.
  resource :onboarding, only: :show, controller: "onboarding"
  resources :households, only: %i[new create show] do
    member { patch :activate }
  end
  # Rejoindre un foyer via code d'invitation.
  resource :membership, only: %i[new create]

  # Module Courses (Phase 2.a).
  resources :shopping_lists, only: %i[index show new create destroy] do
    resources :items, only: %i[create update destroy], controller: "shopping_list_items" do
      member do
        patch :toggle
        post :move_to_fridge
      end
    end
  end
  resources :products, only: :index

  # Module Frigo (Phase 2.a).
  resource :fridge, only: :show, controller: "fridge"
  resources :fridge_items, only: %i[create edit update destroy] do
    member { post :move_to_shopping_list }
  end
  resources :prepared_dishes, only: %i[create destroy]

  # Module Recettes (Phase 2.a).
  resources :recipes do
    member do
      get :cook
      post :add_to_shopping_list
    end
    collection do
      get :new_import
      post :import
    end
  end

  # Module Tâches (Phase 2.a).
  resources :tasks, only: %i[index create edit update destroy] do
    member { patch :toggle }
  end
  resources :task_categories, only: %i[create destroy]

  # Module Calendrier (Phase 2.a).
  resource :calendar, only: :show, controller: "calendar"
  resources :calendar_events, only: %i[new create edit update destroy]

  # Modules satellites (Phase 2.b).
  resources :notes, only: %i[index create edit update destroy] do
    member do
      patch :toggle_favorite
      patch :toggle_archive
      post :promote_to_task
    end
  end
  resources :contacts, only: %i[index new create edit update destroy]
  resources :contact_tags, only: %i[create destroy]
  resources :addresses, only: %i[index new create edit update destroy]
  resources :service_providers, only: %i[index new create edit update destroy]
  resources :service_provider_types, only: %i[create destroy]
  resources :loyalty_cards, only: %i[index show new create edit update destroy]
  resources :pets do
    resources :vaccinations, only: %i[create destroy], controller: "pet_vaccinations"
    resources :treatments, only: %i[create destroy], controller: "pet_treatments"
    resources :supplies, only: %i[create destroy], controller: "pet_supplies"
  end
  resources :vehicles do
    resources :maintenance_entries, only: %i[create destroy], controller: "vehicle_maintenance_entries"
  end
  resources :wine_cellars, only: %i[index create destroy]
  resources :bottles, only: %i[create update destroy] do
    member { patch :toggle_stock }
  end
  resource :waste, only: :show, controller: "waste"
  resources :waste_collection_series, only: %i[create destroy]
  resources :waste_collection_events, only: %i[create destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "design-system", to: "design_system#index"

  # Tableau de bord du foyer (CDC §7).
  root "dashboard#show"
end
