# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_03_130005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "address_type", default: "autre", null: false
    t.datetime "created_at", null: false
    t.text "full_address"
    t.bigint "household_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "phone"
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.index ["household_id", "address_type"], name: "index_addresses_on_household_id_and_address_type"
    t.index ["household_id"], name: "index_addresses_on_household_id"
  end

  create_table "allergen_tests", force: :cascade do |t|
    t.string "allergen", null: false
    t.bigint "baby_profile_id", null: false
    t.datetime "created_at", null: false
    t.string "severity"
    t.date "tested_on"
    t.datetime "updated_at", null: false
    t.index ["baby_profile_id"], name: "index_allergen_tests_on_baby_profile_id"
  end

  create_table "baby_profiles", force: :cascade do |t|
    t.date "born_on"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_baby_profiles_on_household_id"
  end

  create_table "bottles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.boolean "in_stock", default: true, null: false
    t.string "name", null: false
    t.string "region"
    t.datetime "updated_at", null: false
    t.integer "vintage"
    t.bigint "wine_cellar_id", null: false
    t.string "wine_type"
    t.index ["household_id"], name: "index_bottles_on_household_id"
    t.index ["wine_cellar_id"], name: "index_bottles_on_wine_cellar_id"
  end

  create_table "budget_categories", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "emoji"
    t.bigint "household_id", null: false
    t.string "kind", default: "expense", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_budget_categories_on_household_id"
  end

  create_table "budget_entries", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "budget_category_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.string "periodicity", default: "monthly", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_category_id"], name: "index_budget_entries_on_budget_category_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.string "color", default: "blue", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "frequency", default: "none", null: false
    t.bigint "household_id", null: false
    t.string "location"
    t.integer "recurrence_interval", default: 1, null: false
    t.date "recurrence_until"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "starts_at"], name: "index_calendar_events_on_household_id_and_starts_at"
    t.index ["household_id"], name: "index_calendar_events_on_household_id"
  end

  create_table "contact_taggings", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.bigint "contact_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "contact_tag_id"], name: "index_contact_taggings_on_contact_id_and_contact_tag_id", unique: true
    t.index ["contact_id"], name: "index_contact_taggings_on_contact_id"
    t.index ["contact_tag_id"], name: "index_contact_taggings_on_contact_tag_id"
  end

  create_table "contact_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "emoji"
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_contact_tags_on_household_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.date "born_on"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.boolean "year_known", default: true, null: false
    t.index ["household_id"], name: "index_contacts_on_household_id"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id", "user_id"], name: "index_conversation_participants_on_conversation_id_and_user_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_conversations_on_household_id"
  end

  create_table "event_participants", force: :cascade do |t|
    t.bigint "calendar_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["calendar_event_id", "user_id"], name: "index_event_participants_on_calendar_event_id_and_user_id", unique: true
    t.index ["calendar_event_id"], name: "index_event_participants_on_calendar_event_id"
    t.index ["user_id"], name: "index_event_participants_on_user_id"
  end

  create_table "feeding_sessions", force: :cascade do |t|
    t.bigint "baby_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.string "kind", default: "bottle", null: false
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.index ["baby_profile_id"], name: "index_feeding_sessions_on_baby_profile_id"
  end

  create_table "food_introductions", force: :cascade do |t|
    t.string "acceptance"
    t.bigint "baby_profile_id", null: false
    t.datetime "created_at", null: false
    t.string "food", null: false
    t.date "introduced_on"
    t.datetime "updated_at", null: false
    t.index ["baby_profile_id"], name: "index_food_introductions_on_baby_profile_id"
  end

  create_table "fridge_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_on"
    t.bigint "household_id", null: false
    t.string "location", null: false
    t.string "name", null: false
    t.bigint "product_id"
    t.datetime "updated_at", null: false
    t.index ["household_id", "location"], name: "index_fridge_items_on_household_id_and_location"
    t.index ["household_id"], name: "index_fridge_items_on_household_id"
    t.index ["product_id"], name: "index_fridge_items_on_product_id"
  end

  create_table "households", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invite_code", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_code"], name: "index_households_on_invite_code", unique: true
  end

  create_table "loyalty_cards", force: :cascade do |t|
    t.string "code_format", default: "barcode", null: false
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.string "number", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_loyalty_cards_on_household_id"
  end

  create_table "meal_plan_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "free_name"
    t.bigint "household_id", null: false
    t.string "meal_type", default: "dinner", null: false
    t.date "on_date", null: false
    t.integer "position", default: 0, null: false
    t.bigint "recipe_id"
    t.datetime "updated_at", null: false
    t.index ["household_id", "on_date"], name: "index_meal_plan_entries_on_household_id_and_on_date"
    t.index ["household_id"], name: "index_meal_plan_entries_on_household_id"
    t.index ["recipe_id"], name: "index_meal_plan_entries_on_recipe_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["household_id"], name: "index_memberships_on_household_id"
    t.index ["user_id", "household_id"], name: "index_memberships_on_user_id_and_household_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.text "content", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_messages_on_author_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "notes", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.bigint "author_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.boolean "favorite", default: false, null: false
    t.bigint "household_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_notes_on_author_id"
    t.index ["household_id", "archived"], name: "index_notes_on_household_id_and_archived"
    t.index ["household_id"], name: "index_notes_on_household_id"
  end

  create_table "pet_supplies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.date "next_order_on"
    t.string "order_url"
    t.bigint "pet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_pet_supplies_on_pet_id"
  end

  create_table "pet_treatments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "frequency"
    t.date "last_done_on"
    t.string "name", null: false
    t.bigint "pet_id", null: false
    t.decimal "price", precision: 8, scale: 2
    t.string "quantity"
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_pet_treatments_on_pet_id"
  end

  create_table "pet_vaccinations", force: :cascade do |t|
    t.date "booster_on"
    t.datetime "created_at", null: false
    t.date "injected_on"
    t.string "name", null: false
    t.bigint "pet_id", null: false
    t.decimal "price", precision: 8, scale: 2
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_pet_vaccinations_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.date "born_on"
    t.string "breed"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "identifier"
    t.string "name", null: false
    t.string "species"
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 6, scale: 2
    t.index ["household_id"], name: "index_pets_on_household_id"
  end

  create_table "plants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "location"
    t.string "name", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_plants_on_household_id"
  end

  create_table "pool_actions", force: :cascade do |t|
    t.string "action_type", null: false
    t.datetime "created_at", null: false
    t.date "done_on", null: false
    t.text "note"
    t.bigint "pool_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pool_id"], name: "index_pool_actions_on_pool_id"
  end

  create_table "pool_readings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "measure_type", null: false
    t.date "measured_on", null: false
    t.bigint "pool_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 8, scale: 2
    t.index ["pool_id"], name: "index_pool_readings_on_pool_id"
  end

  create_table "pools", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.string "treatment_type", default: "chlore", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_pools_on_household_id"
  end

  create_table "prepared_dishes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_on"
    t.bigint "household_id", null: false
    t.string "location", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "location"], name: "index_prepared_dishes_on_household_id_and_location"
    t.index ["household_id"], name: "index_prepared_dishes_on_household_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "barcode"
    t.string "brand"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.string "rayon"
    t.datetime "updated_at", null: false
    t.index ["barcode"], name: "index_products_on_barcode"
    t.index ["household_id", "name"], name: "index_products_on_household_id_and_name", unique: true
    t.index ["household_id"], name: "index_products_on_household_id"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.decimal "quantity", precision: 10, scale: 2
    t.bigint "recipe_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipe_steps", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "recipe_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_steps_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "category"
    t.integer "cook_time_minutes"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.integer "prep_time_minutes"
    t.integer "servings"
    t.string "source_url"
    t.string "tags", default: [], null: false, array: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_recipes_on_household_id"
  end

  create_table "routine_completions", force: :cascade do |t|
    t.bigint "author_id"
    t.date "completed_on", null: false
    t.datetime "created_at", null: false
    t.bigint "routine_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_routine_completions_on_author_id"
    t.index ["routine_id"], name: "index_routine_completions_on_routine_id"
  end

  create_table "routines", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "emoji"
    t.string "frequency", default: "weekly", null: false
    t.bigint "household_id", null: false
    t.integer "interval", default: 1, null: false
    t.string "list_name"
    t.string "name", null: false
    t.date "next_due_on"
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_routines_on_assignee_id"
    t.index ["household_id"], name: "index_routines_on_household_id"
  end

  create_table "savings_envelopes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.decimal "recurring_deposit", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_savings_envelopes_on_household_id"
  end

  create_table "service_provider_types", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "icon"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_service_provider_types_on_household_id"
  end

  create_table "service_providers", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.bigint "service_provider_type_id"
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_service_providers_on_household_id"
    t.index ["service_provider_type_id"], name: "index_service_providers_on_service_provider_type_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "active_household_id"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["active_household_id"], name: "index_sessions_on_active_household_id"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shared_expenses", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "shared_project_id", null: false
    t.bigint "shared_project_participant_id"
    t.date "spent_on"
    t.datetime "updated_at", null: false
    t.index ["shared_project_id"], name: "index_shared_expenses_on_shared_project_id"
    t.index ["shared_project_participant_id"], name: "index_shared_expenses_on_shared_project_participant_id"
  end

  create_table "shared_project_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "shared_project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["shared_project_id"], name: "index_shared_project_participants_on_shared_project_id"
  end

  create_table "shared_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_shared_projects_on_household_id"
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id"
    t.decimal "quantity", precision: 10, scale: 2
    t.string "rayon"
    t.bigint "shopping_list_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_shopping_list_items_on_product_id"
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "icon"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_shopping_lists_on_household_id"
  end

  create_table "task_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_task_categories_on_household_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "done", default: false, null: false
    t.date "due_on"
    t.string "emoji"
    t.bigint "household_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "task_category_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["household_id"], name: "index_tasks_on_household_id"
    t.index ["task_category_id"], name: "index_tasks_on_task_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "vehicle_maintenance_entries", force: :cascade do |t|
    t.decimal "cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.date "done_on"
    t.string "entry_type"
    t.string "provider"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["vehicle_id"], name: "index_vehicle_maintenance_entries_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "energy"
    t.bigint "household_id", null: false
    t.date "inspection_expires_on"
    t.string "manufacturer"
    t.string "name", null: false
    t.string "plate"
    t.datetime "updated_at", null: false
    t.string "vehicle_type", default: "car", null: false
    t.integer "year"
    t.index ["household_id"], name: "index_vehicles_on_household_id"
  end

  create_table "waste_collection_events", force: :cascade do |t|
    t.date "collected_on", null: false
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "waste_collection_series_id"
    t.string "waste_type", null: false
    t.index ["household_id", "collected_on"], name: "index_waste_collection_events_on_household_id_and_collected_on"
    t.index ["household_id"], name: "index_waste_collection_events_on_household_id"
    t.index ["waste_collection_series_id"], name: "index_waste_collection_events_on_waste_collection_series_id"
  end

  create_table "waste_collection_series", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "ends_on", null: false
    t.bigint "household_id", null: false
    t.integer "interval_weeks", default: 1, null: false
    t.date "starts_on", null: false
    t.datetime "updated_at", null: false
    t.string "waste_type", null: false
    t.integer "weekday", null: false
    t.index ["household_id"], name: "index_waste_collection_series_on_household_id"
  end

  create_table "wine_cellars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_wine_cellars_on_household_id"
  end

  add_foreign_key "addresses", "households"
  add_foreign_key "allergen_tests", "baby_profiles"
  add_foreign_key "baby_profiles", "households"
  add_foreign_key "bottles", "households"
  add_foreign_key "bottles", "wine_cellars"
  add_foreign_key "budget_categories", "households"
  add_foreign_key "budget_entries", "budget_categories"
  add_foreign_key "calendar_events", "households"
  add_foreign_key "contact_taggings", "contact_tags"
  add_foreign_key "contact_taggings", "contacts"
  add_foreign_key "contact_tags", "households"
  add_foreign_key "contacts", "households"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "conversations", "households"
  add_foreign_key "event_participants", "calendar_events"
  add_foreign_key "event_participants", "users"
  add_foreign_key "feeding_sessions", "baby_profiles"
  add_foreign_key "food_introductions", "baby_profiles"
  add_foreign_key "fridge_items", "households"
  add_foreign_key "fridge_items", "products"
  add_foreign_key "loyalty_cards", "households"
  add_foreign_key "meal_plan_entries", "households"
  add_foreign_key "meal_plan_entries", "recipes"
  add_foreign_key "memberships", "households"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "author_id"
  add_foreign_key "notes", "households"
  add_foreign_key "notes", "users", column: "author_id"
  add_foreign_key "pet_supplies", "pets"
  add_foreign_key "pet_treatments", "pets"
  add_foreign_key "pet_vaccinations", "pets"
  add_foreign_key "pets", "households"
  add_foreign_key "plants", "households"
  add_foreign_key "pool_actions", "pools"
  add_foreign_key "pool_readings", "pools"
  add_foreign_key "pools", "households"
  add_foreign_key "prepared_dishes", "households"
  add_foreign_key "products", "households"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipe_steps", "recipes"
  add_foreign_key "recipes", "households"
  add_foreign_key "routine_completions", "routines"
  add_foreign_key "routine_completions", "users", column: "author_id"
  add_foreign_key "routines", "households"
  add_foreign_key "routines", "users", column: "assignee_id"
  add_foreign_key "savings_envelopes", "households"
  add_foreign_key "service_provider_types", "households"
  add_foreign_key "service_providers", "households"
  add_foreign_key "service_providers", "service_provider_types"
  add_foreign_key "sessions", "households", column: "active_household_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "shared_expenses", "shared_project_participants"
  add_foreign_key "shared_expenses", "shared_projects"
  add_foreign_key "shared_project_participants", "shared_projects"
  add_foreign_key "shared_projects", "households"
  add_foreign_key "shopping_list_items", "products"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_lists", "households"
  add_foreign_key "task_categories", "households"
  add_foreign_key "tasks", "households"
  add_foreign_key "tasks", "task_categories"
  add_foreign_key "tasks", "users", column: "assignee_id"
  add_foreign_key "vehicle_maintenance_entries", "vehicles"
  add_foreign_key "vehicles", "households"
  add_foreign_key "waste_collection_events", "households"
  add_foreign_key "waste_collection_events", "waste_collection_series"
  add_foreign_key "waste_collection_series", "households"
  add_foreign_key "wine_cellars", "households"
end
