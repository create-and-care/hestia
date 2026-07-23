namespace :demo_data do
  desc "Populate the dev database with fictional data across every module (set HOUSEHOLD_ID to seed an existing household instead of creating one)"
  task default: :environment do
    abort "Refusing to run outside development (current env: #{Rails.env})." unless Rails.env.development?

    require "faker"
    household = DemoData::Seeder.call(household_id: ENV["HOUSEHOLD_ID"].presence)

    puts "Demo data ready for household ##{household.id} (#{household.name})."
    puts "Sign in with demo@hestia.local / password123 (and demo2@hestia.local / password123)." unless ENV["HOUSEHOLD_ID"].presence
  end
end
