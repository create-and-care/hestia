Rails.application.routes.draw do
  # Solid Queue admin UI (Spec §18 — reliability): closed by default behind HTTP
  # Basic Auth until the host configures `mission_control.http_basic_auth_user`/
  # `http_basic_auth_password` via `bin/rails credentials:edit` (see README) —
  # not app-role-gated since it's a whole-instance operator tool, not a
  # per-household feature.
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # UI language preference (English default, French available — Spec §8).
  patch "locale", to: "locales#update", as: :locale

  # Versioned REST/JSON API (Spec §15), consumed by the Flutter mobile client and,
  # eventually, by Hest.AI (Phase 3). Token authentication (ApiToken), household
  # scoping always server-side. Now covers all 25 modules (see Implementation Plan §6).
  namespace :api do
    namespace :v1 do
      resources :shopping_lists, only: %i[index show] do
        resources :items, only: %i[create destroy], controller: "shopping_list_items" do
          member { patch :toggle }
        end
      end
      resources :fridge_items, only: %i[index create]
      resources :recipes, only: %i[index show]
      resources :tasks, only: %i[index create] do
        member { patch :toggle }
      end
      resources :calendar_events, only: :index

      resources :notes, only: %i[index create]
      resources :contacts, only: %i[index show]
      resources :addresses, only: %i[index]
      resources :service_providers, only: %i[index]
      resources :loyalty_cards, only: %i[index]
      resources :pets, only: %i[index show]
      resources :vehicles, only: %i[index show]

      resources :bottles, only: %i[index]
      resources :wine_cellars, only: [] do
        resources :bottles, only: %i[create]
      end
      resources :waste_collection_events, only: %i[index create]
      resources :baby_profiles, only: [] do
        resources :feeding_sessions, only: %i[index create]
      end
      resources :conversations, only: %i[index] do
        resources :messages, only: %i[create]
      end
      resources :meal_plan_entries, only: %i[index create]
      resources :routines, only: %i[index] do
        member { post :complete }
      end
      resources :plants, only: %i[index]

      resources :budget_entries, only: %i[index create]
      resources :documents, only: :index
      resources :gift_lists, only: :index do
        resources :gift_ideas, only: :create
      end
      resources :circles, only: [] do
        resources :posts, only: %i[index create], controller: "circle_posts"
      end
      resources :trips, only: %i[index show]
      resources :weight_entries, only: %i[index create]
      resources :workout_entries, only: %i[index create]
    end
  end

  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  # Onboarding: choosing to create / join a household.
  resource :onboarding, only: :show, controller: "onboarding"
  resources :households, only: %i[new create show update] do
    member do
      patch :activate
      patch :update_modules
    end
  end
  # Joining a household via an invite code.
  resource :membership, only: %i[new create]

  # Reminders & notifications (Spec §9.2, §9.3, §9.4, §10.2).
  resources :notifications, only: :index do
    collection { patch :mark_all_read }
    member { patch :mark_read }
  end
  # Rendered as a section of household settings (households#show), not a page of its own.
  resource :notification_preference, only: %i[update]

  # API tokens for the mobile client (Spec §15). Also rendered as a section of
  # household settings (households#show), not a page of its own.
  resources :api_tokens, only: %i[create destroy]

  # External calendar sync: real Google/Microsoft OAuth + CalDAV (Spec §9.2, §16).
  resources :external_calendar_connections, only: %i[index create destroy] do
    collection do
      get ":provider/connect", to: "external_calendar_connections#connect", as: :connect
      get ":provider/callback", to: "external_calendar_connections#callback", as: :callback
    end
  end

  # Shopping module (Phase 2.a).
  resources :shopping_lists, only: %i[index show new create destroy] do
    resources :items, only: %i[create update destroy], controller: "shopping_list_items" do
      member do
        patch :toggle
        post :move_to_fridge
        patch :move_up
        patch :move_down
      end
      collection do
        patch :reorder
        delete :clear_checked
      end
    end
  end
  resources :products, only: :index do
    collection { get :lookup }
    member { post :add_to_list }
  end

  # Fridge module (Phase 2.a).
  resource :fridge, only: :show, controller: "fridge"
  resources :fridge_items, only: %i[create edit update destroy] do
    member { post :move_to_shopping_list }
  end
  resources :prepared_dishes, only: %i[create destroy]

  # Recipe catalog ("Découvrir" tab) — read-only, cloned into the household's
  # own book on demand (Recipes::Catalog::AddToHousehold). Declared before
  # `resources :recipes` so "/recipes/catalog" isn't swallowed by the
  # "/recipes/:id" show route.
  get "recipes/catalog", to: "recipe_catalog#index", as: :recipe_catalog
  post "recipes/catalog/:id/add_to_household", to: "recipe_catalog#add_to_household", as: :add_to_household_recipe_catalog

  # Recipes module (Phase 2.a).
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

  # Tasks module (Phase 2.a).
  resources :tasks, only: %i[index create edit update destroy] do
    member { patch :toggle }
    collection { patch :reorder }
    resources :task_reminders, only: %i[create destroy]
  end
  resources :task_categories, only: %i[create destroy]

  # Calendar module (Phase 2.a).
  resource :calendar, only: :show, controller: "calendar"
  resources :calendar_events, only: %i[new create edit update destroy] do
    resources :event_reminders, only: %i[create destroy]
  end

  # Satellite modules (Phase 2.b).
  resources :notes, only: %i[index create edit update destroy] do
    member do
      patch :toggle_favorite
      patch :toggle_archive
      post :promote_to_task
    end
  end
  resources :contacts, only: %i[index new create edit update destroy]
  resources :contact_tags, only: %i[create destroy]
  resources :addresses, only: %i[index new create edit update destroy] do
    collection { get :search }
  end
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

  # Modules with richer business logic (Phase 2.c).
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

  # Modules with an architecture deviation (Phase 2.d).
  resources :gift_lists, only: %i[index show create edit update destroy] do
    resource :share, only: %i[create destroy], controller: "gift_list_shares"
    resources :gift_ideas, only: %i[create update destroy]
  end
  # Unauthenticated public sharing of wish lists (Spec §5).
  get    "g/:token",              to: "public_gift_lists#show",      as: :public_gift_list
  post   "g/:token/reserve/:idea_id", to: "public_gift_lists#reserve",   as: :reserve_public_gift
  delete "g/:token/reserve/:idea_id", to: "public_gift_lists#unreserve", as: :unreserve_public_gift

  # Circles (independent of the household, Spec §5, point 1).
  resources :circles, only: %i[index show create edit update destroy] do
    resources :posts, only: %i[create destroy], controller: "circle_posts"
    resources :members, only: %i[update destroy], controller: "circle_memberships"
    post "regenerate_invite_code", on: :member
  end
  resource :circle_membership, only: %i[new create]
  post   "circle_posts/:id/react", to: "circle_post_reactions#create",  as: :react_circle_post
  delete "circle_posts/:id/react", to: "circle_post_reactions#destroy", as: :unreact_circle_post

  # Trip: cross-cutting context (Spec §5, point 3 / §12.3).
  resources :trips, only: %i[index show create destroy] do
    resources :notes, only: %i[create destroy], module: :trips
    resources :tasks, only: %i[create destroy], module: :trips
    resources :addresses, only: %i[create destroy], module: :trips
    resources :shopping_lists, only: %i[create destroy], module: :trips
  end

  # Wellbeing: data strictly private to the user (Spec §5, point 4).
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
  get "design-system/colors", to: "design_system#colors"
  get "design-system/typography", to: "design_system#typography"
  get "design-system/icons", to: "design_system#icons"
  get "design-system/components/:id", to: "design_system#component", as: :design_system_component

  # Global command-palette search (sidebar) — searches across all household
  # modules at once (Household improvements backlog item).
  resource :search, only: :show

  # Household dashboard (Spec §7).
  root "dashboard#show"
end
