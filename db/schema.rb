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

ActiveRecord::Schema[8.1].define(version: 2026_07_02_130001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "event_participants", force: :cascade do |t|
    t.bigint "calendar_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["calendar_event_id", "user_id"], name: "index_event_participants_on_calendar_event_id_and_user_id", unique: true
    t.index ["calendar_event_id"], name: "index_event_participants_on_calendar_event_id"
    t.index ["user_id"], name: "index_event_participants_on_user_id"
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

  add_foreign_key "calendar_events", "households"
  add_foreign_key "event_participants", "calendar_events"
  add_foreign_key "event_participants", "users"
  add_foreign_key "fridge_items", "households"
  add_foreign_key "fridge_items", "products"
  add_foreign_key "memberships", "households"
  add_foreign_key "memberships", "users"
  add_foreign_key "prepared_dishes", "households"
  add_foreign_key "products", "households"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipe_steps", "recipes"
  add_foreign_key "recipes", "households"
  add_foreign_key "sessions", "households", column: "active_household_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "shopping_list_items", "products"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_lists", "households"
  add_foreign_key "task_categories", "households"
  add_foreign_key "tasks", "households"
  add_foreign_key "tasks", "task_categories"
  add_foreign_key "tasks", "users", column: "assignee_id"
end
