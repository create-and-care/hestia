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
      collection { patch :reorder }
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
    collection { patch :reorder }
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
  resources :loyalty_cards, only: %i[index show new create edit update destroy] do
    collection { patch :reorder }
  end
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
  resources :baby_profiles do
    resources :feeding_sessions, only: %i[create destroy]
    resources :food_introductions, only: %i[create destroy]
    resources :allergen_tests, only: %i[create destroy]
  end
  resources :conversations, only: %i[index show new create edit update] do
    resources :messages, only: :create
  end

  # Modules à logique métier riche (Phase 2.c).
  resource :menu, only: :show, controller: "menu"
  resources :meal_plan_entries, only: %i[create update destroy]
  resources :routines, only: %i[index create edit update destroy] do
    member { post :complete }
  end
  resource :exterior, only: :show, controller: "exterior"
  resources :plants, only: %i[create destroy]
  resources :pools, only: %i[create destroy] do
    resources :pool_readings, only: %i[create destroy]
    resources :pool_actions, only: %i[create destroy]
  end
  resource :budget, only: :show, controller: "budget"
  resources :budget_categories, only: %i[create destroy]
  resources :budget_entries, only: %i[create destroy]
  resources :savings_envelopes, only: %i[create destroy]
  resources :shared_projects, only: %i[index show create destroy] do
    resources :shared_project_participants, only: %i[create destroy]
    resources :shared_expenses, only: %i[create destroy]
  end
  resources :documents, only: %i[index show create destroy]
  resources :document_folders, only: %i[create destroy]

  # Modules à écart d'architecture (Phase 2.d).
  resources :gift_lists, only: %i[index show create destroy] do
    resource :share, only: %i[create destroy], controller: "gift_list_shares"
    resources :gift_ideas, only: %i[create update destroy]
  end
  # Partage public non authentifié des listes d'envies (CDC §5).
  get    "g/:token",              to: "public_gift_lists#show",      as: :public_gift_list
  post   "g/:token/reserve/:idea_id", to: "public_gift_lists#reserve",   as: :reserve_public_gift
  delete "g/:token/reserve/:idea_id", to: "public_gift_lists#unreserve", as: :unreserve_public_gift

  # Cercles (indépendants du foyer, CDC §5, point 1).
  resources :circles, only: %i[index show create] do
    resources :posts, only: %i[create destroy], controller: "circle_posts"
  end
  resource :circle_membership, only: %i[new create]
  post   "circle_posts/:id/react", to: "circle_post_reactions#create",  as: :react_circle_post
  delete "circle_posts/:id/react", to: "circle_post_reactions#destroy", as: :unreact_circle_post

  # Voyage : contexte transverse (CDC §5, point 3 / §12.3).
  resources :trips, only: %i[index show create destroy] do
    resources :notes, only: %i[create destroy], module: :trips
    resources :tasks, only: %i[create destroy], module: :trips
    resources :addresses, only: %i[create destroy], module: :trips
    resources :shopping_lists, only: %i[create destroy], module: :trips
  end

  # Bien-être : données strictement privées à l'utilisateur (CDC §5, point 4).
  resource :wellbeing, only: :show, controller: "wellbeing"
  resource :wellbeing_profile, only: :update
  resources :weight_entries, only: %i[create destroy]
  resources :workout_entries, only: %i[create destroy]

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
