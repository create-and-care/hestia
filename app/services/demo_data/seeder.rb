module DemoData
  # Populates a household with realistic-looking fictional data across (almost)
  # every module, so a fresh dev database has enough variety to exercise every
  # view without having to click through each form by hand.
  #
  # bin/rails demo_data:default              # creates a brand-new "Foyer Démo" household
  # HOUSEHOLD_ID=42 bin/rails demo_data:default  # seeds an existing household instead
  #
  # Not idempotent — running it twice adds a second batch of everything.
  class Seeder
    DEMO_USERS = [
      { email_address: "demo@hestia.local", name: "Alex Démo", role: "admin" },
      { email_address: "demo2@hestia.local", name: "Sacha Démo", role: "member" }
    ].freeze

    def self.call(household_id: nil)
      new(household_id: household_id).call
    end

    def initialize(household_id: nil)
      @household_id = household_id
    end

    def call
      Faker::Config.locale = "fr"

      ActiveRecord::Base.transaction do
        resolve_household_and_users
        seed_contacts
        seed_addresses
        seed_service_providers
        seed_vehicles
        seed_pets
        seed_wine_cellar
        seed_loyalty_cards
        seed_food
        seed_recipes
        seed_meal_plan
        seed_tasks
        seed_routines
        seed_notes
        seed_documents
        seed_budget
        seed_waste
        seed_baby
        seed_plants
        seed_pools
        seed_gifts
        seed_trips
        seed_circles_and_conversations
        seed_calendar
        seed_wellbeing
        seed_notifications
      end

      @household
    end

    private
      def resolve_household_and_users
        if @household_id
          @household = Household.find(@household_id)
          @users = @household.users.to_a
          raise "Household #{@household.id} has no members" if @users.empty?
        else
          @users = DEMO_USERS.map do |attrs|
            User.find_or_create_by!(email_address: attrs[:email_address]) do |user|
              user.password = "password123"
              user.name = attrs[:name]
              user.locale = "fr"
            end
          end

          @household = Household.create!(name: "Foyer Démo", time_zone: "Paris", holiday_country: "FR")
          @users.each_with_index { |user, i| @household.memberships.create!(user: user, role: DEMO_USERS[i][:role]) }
          @household.shopping_lists.create!(name: "Courses de la semaine")
        end

        @admin = @users.first
      end

      def seed_contacts
        tags = [ [ "👪", "Famille" ], [ "🤝", "Amis" ], [ "💼", "Travail" ] ].map do |emoji, name|
          @household.contact_tags.create!(emoji: emoji, name: name)
        end

        @contacts = Array.new(8) do
          contact = @household.contacts.create!(
            name: Faker::Name.name,
            born_on: Faker::Date.birthday(min_age: 1, max_age: 85),
            year_known: [ true, true, false ].sample
          )
          contact.contact_tags << tags.sample(rand(0..2))
          contact
        end
      end

      def seed_addresses
        10.times do
          @household.addresses.create!(
            name: Faker::Restaurant.name,
            address_type: Address::TYPES.sample,
            full_address: "#{Faker::Address.street_address}, #{Faker::Address.zip_code} #{Faker::Address.city}",
            phone: Faker::PhoneNumber.phone_number,
            rating: [ nil, 3, 4, 5 ].sample
          )
        end
      end

      def seed_service_providers
        types = [ [ "🔧", "gray", "Plombier" ], [ "⚡", "yellow", "Électricien" ], [ "🌳", "green", "Jardinier" ], [ "🏠", "blue", "Femme de ménage" ] ].map do |icon, color, name|
          @household.service_provider_types.create!(icon: icon, color: color, name: name)
        end

        8.times do
          @household.service_providers.create!(
            name: Faker::Company.name,
            service_provider_type: types.sample,
            phone: Faker::PhoneNumber.phone_number,
            email: Faker::Internet.email,
            address: Faker::Address.full_address
          )
        end
      end

      def seed_vehicles
        2.times do
          vehicle = @household.vehicles.create!(
            name: Faker::Vehicle.make_and_model,
            vehicle_type: Vehicle::TYPES.sample,
            manufacturer: Faker::Vehicle.manufacture,
            plate: Faker::Vehicle.license_plate,
            year: rand(2012..2024),
            energy: %w[essence diesel electrique hybride].sample,
            inspection_expires_on: Faker::Date.forward(days: rand(-30..300))
          )
          rand(1..3).times do
            vehicle.vehicle_maintenance_entries.create!(
              entry_type: %w[revision vidange pneus controle_technique].sample,
              done_on: Faker::Date.backward(days: 300),
              cost: rand(50..600),
              description: Faker::Lorem.sentence
            )
          end
        end
      end

      def seed_pets
        [ [ "Chien", "Golden Retriever" ], [ "Chat", "Européen" ] ].each do |species, breed|
          pet = @household.pets.create!(
            name: Faker::Creature::Dog.name,
            species: species,
            breed: breed,
            born_on: Faker::Date.birthday(min_age: 1, max_age: 12),
            weight: rand(2.0..35.0).round(1)
          )
          pet.pet_vaccinations.create!(name: "Rage", injected_on: Faker::Date.backward(days: 200), booster_on: Faker::Date.forward(days: 165), price: rand(30..80))
          pet.pet_treatments.create!(name: "Antipuce", frequency: "monthly", last_done_on: Faker::Date.backward(days: 20), price: rand(10..30))
          pet.pet_supplies.create!(name: "Croquettes", next_order_on: Faker::Date.forward(days: 15))
        end
      end

      def seed_wine_cellar
        cellar = @household.wine_cellars.create!(name: "Cave principale")
        12.times do
          cellar.bottles.create!(
            household: @household,
            name: "Château #{Faker::Name.last_name}",
            vintage: rand(2010..2023),
            region: [ "Bordeaux", "Bourgogne", "Vallée du Rhône", "Loire", "Alsace", "Provence" ].sample,
            wine_type: Bottle::WINE_TYPES.sample,
            in_stock: [ true, true, true, false ].sample
          )
        end
      end

      def seed_loyalty_cards
        brands = LoyaltyBrand.all.to_a
        6.times do |i|
          brand = brands[i % brands.size] if brands.any?
          @household.loyalty_cards.create!(
            name: brand&.name || Faker::Company.name,
            loyalty_brand: brand,
            number: Faker::Number.number(digits: 12).to_s,
            code_format: brand&.code_format || "barcode",
            position: i
          )
        end
      end

      def seed_food
        product_names = [ "Lait demi-écrémé", "Yaourts nature", "Pommes Gala", "Poulet fermier", "Pâtes penne",
                          "Riz basmati", "Tomates cerises", "Fromage comté", "Jus d'orange", "Beurre doux" ]
        products = product_names.map do |name|
          @household.products.find_or_create_by!(name: name) do |product|
            product.rayon = ShoppingListItem::RAYONS.sample
            product.brand = Faker::Company.name
          end
        end

        products.sample(6).each do |product|
          @household.fridge_items.create!(name: product.name, product: product, location: FridgeItem::LOCATIONS.sample,
            expires_on: Faker::Date.forward(days: rand(-2..20)))
        end

        3.times do
          @household.prepared_dishes.create!(name: Faker::Food.dish, location: FridgeItem::LOCATIONS.sample,
            expires_on: Faker::Date.forward(days: rand(1..7)))
        end

        list = @household.shopping_lists.first
        products.sample(5).each do |product|
          list.items.create!(name: product.name, product: product, quantity: rand(1..3),
            unit: %w[kg pièce L paquet].sample, rayon: product.rayon)
        end
      end

      def seed_recipes
        recipe_defs = [
          { title: "Poulet rôti aux herbes", category: "plat", servings: 4, prep: 15, cook: 60,
            ingredients: [ [ "Poulet fermier", 1, "pièce" ], [ "Thym", 2, "brins" ], [ "Ail", 4, "gousses" ] ],
            steps: [ "Préchauffer le four à 200°C.", "Frotter le poulet avec l'ail et le thym.", "Enfourner 1h en arrosant régulièrement." ] },
          { title: "Salade de pâtes estivale", category: "entree", servings: 4, prep: 20, cook: 10,
            ingredients: [ [ "Pâtes penne", 400, "g" ], [ "Tomates cerises", 250, "g" ], [ "Mozzarella", 200, "g" ] ],
            steps: [ "Cuire les pâtes al dente.", "Couper les tomates et la mozzarella.", "Mélanger le tout avec un filet d'huile d'olive." ] },
          { title: "Tarte aux pommes", category: "dessert", servings: 6, prep: 20, cook: 35,
            ingredients: [ [ "Pâte brisée", 1, "pièce" ], [ "Pommes Gala", 5, "pièce" ], [ "Sucre", 80, "g" ] ],
            steps: [ "Étaler la pâte dans un moule.", "Disposer les pommes coupées en lamelles.", "Saupoudrer de sucre et cuire 35 min." ] }
        ]

        @recipes = recipe_defs.map do |data|
          recipe = @household.recipes.create!(title: data[:title], category: data[:category], servings: data[:servings],
            prep_time_minutes: data[:prep], cook_time_minutes: data[:cook], tags: [ data[:category] ])
          data[:ingredients].each_with_index { |(name, qty, unit), i| recipe.recipe_ingredients.create!(name: name, quantity: qty, unit: unit, position: i) }
          data[:steps].each_with_index { |content, i| recipe.recipe_steps.create!(content: content, position: i) }
          recipe
        end
      end

      def seed_meal_plan
        (0..6).each do |offset|
          @household.meal_plan_entries.create!(on_date: Date.current + offset, meal_type: %w[lunch dinner].sample, recipe: @recipes.sample)
        end
      end

      def seed_tasks
        categories = [ "Maison", "Administratif", "Courses" ].map { |name| @household.task_categories.create!(name: name) }
        15.times do |i|
          @household.tasks.create!(
            title: Faker::Lorem.sentence(word_count: 3).chomp("."),
            description: [ nil, Faker::Lorem.sentence ].sample,
            task_category: categories.sample,
            assignee: @users.sample,
            due_on: [ nil, Faker::Date.forward(days: rand(1..21)) ].sample,
            done: [ true, false, false ].sample,
            position: i
          )
        end
      end

      def seed_routines
        [ [ "🧹", "Passer l'aspirateur", "weekly" ], [ "🧺", "Lessive", "weekly" ],
          [ "🪴", "Arroser les plantes", "daily" ], [ "🧼", "Nettoyer la salle de bain", "monthly" ] ].each do |emoji, name, freq|
          routine = @household.routines.create!(emoji: emoji, name: name, frequency: freq, assignee: @users.sample)
          rand(1..4).times { |i| routine.routine_completions.create!(completed_on: Date.current - (i * 7), author: @users.sample) }
        end
      end

      def seed_notes
        5.times do
          @household.notes.create!(title: Faker::Lorem.sentence(word_count: 4).chomp("."), content: Faker::Lorem.paragraph,
            color: Note::COLORS.sample, author: @users.sample, favorite: [ true, false, false ].sample)
        end
      end

      def seed_documents
        folders = [ [ "Factures", "blue" ], [ "Contrats", "green" ], [ "Santé", "red" ] ].map do |name, color|
          @household.document_folders.create!(name: name, color: color)
        end

        folders.each do |folder|
          2.times do
            document = @household.documents.new(name: "#{folder.name} - #{Faker::Lorem.word}", document_folder: folder)
            document.file.attach(io: StringIO.new("Document fictif généré par demo_data:default."), filename: "demo.txt", content_type: "text/plain")
            document.save!
          end
        end
      end

      def seed_budget
        income = @household.budget_categories.create!(name: "Salaire", kind: "income", emoji: "💰")
        income.budget_entries.create!(amount: 2400, name: "Salaire net", periodicity: "monthly")

        [ [ "Logement", "🏠", 950 ], [ "Alimentation", "🛒", 450 ], [ "Transport", "🚗", 180 ], [ "Loisirs", "🎉", 120 ] ].each do |name, emoji, amount|
          category = @household.budget_categories.create!(name: name, kind: "expense", emoji: emoji)
          category.budget_entries.create!(amount: amount, name: name, periodicity: "monthly")
        end

        @household.savings_envelopes.create!(name: "Vacances", recurring_deposit: 100)
        @household.savings_envelopes.create!(name: "Épargne de précaution", recurring_deposit: 200)
      end

      def seed_waste
        today = Date.current
        series = @household.waste_collection_series.create!(waste_type: "ordures", weekday: today.wday, starts_on: today - 30, ends_on: today + 300, interval_weeks: 1)
        4.times { |i| @household.waste_collection_events.create!(waste_type: "ordures", collected_on: today + (i * 7), waste_collection_series: series) }
        @household.waste_collection_events.create!(waste_type: "verre", collected_on: today + 10)
      end

      def seed_baby
        baby = @household.baby_profiles.create!(name: Faker::Name.first_name, born_on: Faker::Date.backward(days: 200))
        baby.feeding_sessions.create!(kind: "bottle", started_at: 2.hours.ago, ended_at: 2.hours.ago + 20.minutes)
        baby.feeding_sessions.create!(kind: "breast", started_at: 6.hours.ago, ended_at: 6.hours.ago + 15.minutes)
        baby.food_introductions.create!(food: "Carotte", introduced_on: Date.current - 10, acceptance: "aimé")
        baby.food_introductions.create!(food: "Kiwi", introduced_on: Date.current - 3, acceptance: "neutre")
        baby.allergen_tests.create!(allergen: "Arachide", tested_on: Date.current - 5, severity: "aucune")
      end

      def seed_plants
        references = PlantReference.all.to_a
        [ "Salon", "Cuisine", "Balcon" ].each do |location|
          reference = references.sample
          plant = @household.plants.create!(name: reference&.common_name || "Plante verte", location: location, plant_reference: reference)
          plant.plant_care_tasks.create!(care_type: "arrosage", frequency: "weekly", interval: 1, next_due_on: Date.current + rand(1..5))
        end
      end

      def seed_pools
        pool = @household.pools.create!(name: "Piscine", treatment_type: "chlore")
        5.times { |i| pool.pool_readings.create!(measure_type: "pH", measured_on: Date.current - i, value: rand(6.8..7.6).round(2)) }
        3.times { |i| pool.pool_readings.create!(measure_type: "chlore_libre", measured_on: Date.current - i, value: rand(0.5..3.0).round(2)) }
        pool.pool_actions.create!(action_type: "traitement_choc", done_on: Date.current - 3, note: "Traitement choc après forte chaleur")
      end

      def seed_gifts
        contact = @contacts.first
        receive_list = @household.gift_lists.create!(name: "Ma liste de Noël", perspective: "receive", created_by: @admin)
        receive_list.gift_ideas.create!(name: "Casque audio", price: 89.99, status: "wanted")
        receive_list.gift_ideas.create!(name: "Livre de cuisine", price: 24.90, status: "bought")

        give_list = @household.gift_lists.create!(name: "Anniversaire de #{contact&.name || 'Chloé'}", perspective: "give", contact: contact, created_by: @admin)
        give_list.gift_ideas.create!(name: "Plante d'intérieur", price: 35, status: "wanted")
      end

      def seed_trips
        trip = @household.trips.create!(name: "Week-end à Annecy", starts_on: Date.current + 20, ends_on: Date.current + 22)
        trip.tasks.create!(household: @household, title: "Réserver le gîte", assignee: @admin)
        trip.notes.create!(household: @household, title: "Idées d'activités", content: "Randonnée, paddle, marché du samedi.")
        trip.addresses.create!(household: @household, name: "Gîte Le Vieux Chalet", address_type: "autre",
          full_address: "12 chemin des Prés, 74000 Annecy")
        trip.shopping_lists.create!(household: @household, name: "Courses week-end")
        trip.meal_plan_entries.create!(household: @household, on_date: trip.starts_on, meal_type: "dinner", free_name: "Restaurant en ville")

        project = trip.create_shared_project!(household: @household, name: trip.name)
        participants = @users.map { |user| project.shared_project_participants.create!(name: user.name) }
        project.shared_expenses.create!(amount: 180, description: "Essence", spent_on: Date.current + 20, shared_project_participant: participants.first)
        project.shared_expenses.create!(amount: 95, description: "Courses", spent_on: Date.current + 21, shared_project_participant: participants.second)
      end

      def seed_circles_and_conversations
        circle = Circle.create!(name: "Amis d'enfance", theme: "Groupe photo")
        @users.each_with_index { |user, i| circle.circle_memberships.create!(user: user, role: i.zero? ? "admin" : "member") }
        post = circle.circle_posts.create!(author: @admin, body: "On se motive pour une prochaine soirée ?")
        post.circle_post_reactions.create!(user: @users.last, emoji: "🎉")

        conversation = @household.conversations.create!(name: "Foyer")
        @users.each { |user| conversation.conversation_participants.create!(user: user) }
        conversation.messages.create!(author: @admin, content: "Salut, on planifie quoi pour ce soir ?")
        conversation.messages.create!(author: @users.last, content: "Pourquoi pas les pâtes au pesto de la nouvelle recette ?")
      end

      def seed_calendar
        event = @household.calendar_events.create!(title: "Rendez-vous vétérinaire", starts_at: 3.days.from_now.change(hour: 10),
          ends_at: 3.days.from_now.change(hour: 11), color: "blue", event_type: "rdv")
        event.event_participants.create!(user: @admin)
        @household.calendar_events.create!(title: "Anniversaire de #{@users.last.name}", starts_at: 10.days.from_now.beginning_of_day,
          all_day: true, color: "orange")
      end

      def seed_wellbeing
        @users.each do |user|
          next if user.wellbeing_profile

          user.create_wellbeing_profile!(sex: WellbeingProfile::SEXES.sample, age: rand(25..45), height: rand(155..190),
            activity_level: WellbeingProfile::ACTIVITY_LEVELS.sample, start_weight: rand(60..90), goal_weight: rand(60..80))
          8.times { |i| user.weight_entries.create!(recorded_on: Date.current - (i * 7), weight: rand(65.0..85.0).round(1)) }
          4.times { |i| user.workout_entries.create!(exercise: %w[Course Musculation Natation Vélo].sample, done_on: Date.current - (i * 3), duration_minutes: rand(20..60)) }
        end
      end

      def seed_notifications
        Notification.create!(household: @household, user: @admin, kind: "fridge_expiry", title: "Un article du frigo expire bientôt",
          body: "Lait demi-écrémé expire demain.")
        Notification.create!(household: @household, user: @admin, kind: "birthday", title: "Anniversaire à venir",
          body: "#{@contacts.first&.name} fête son anniversaire bientôt.")
      end
  end
end
