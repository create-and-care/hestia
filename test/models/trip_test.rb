require "test_helper"

class TripTest < ActiveSupport::TestCase
  test "general scope excludes trip-scoped records" do
    trip_note = households(:alpha).notes.create!(title: "Passeport", trip: trips(:alpha_trip))
    assert_not_includes Note.general, trip_note
    assert_includes Note.general, notes(:alpha_idea)
  end

  test "deleting a trip destroys its attached records" do
    trip = trips(:alpha_trip)
    trip.notes.create!(household: households(:alpha), title: "N")
    trip.tasks.create!(household: households(:alpha), title: "T")
    trip.shopping_lists.create!(household: households(:alpha), name: "L")
    trip.addresses.create!(household: households(:alpha), name: "A", address_type: "autre")
    trip.meal_plan_entries.create!(household: households(:alpha), on_date: Date.current, meal_type: "dinner", free_name: "M")

    assert_difference [ "Note.count", "Task.count", "ShoppingList.count", "Address.count", "MealPlanEntry.count" ], -1 do
      trip.destroy
    end
  end

  test "deleting a trip destroys its linked shared expenses project" do
    trip = trips(:alpha_trip)
    households(:alpha).shared_projects.create!(name: trip.name, trip: trip)

    assert_difference -> { SharedProject.count }, -1 do
      trip.destroy
    end
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).trips, trips(:beta_trip)
  end

  test "all sections are enabled by default" do
    trip = trips(:alpha_trip)
    Trip::SECTIONS.each { |key| assert trip.section_enabled?(key) }
  end

  test "a disabled section is no longer enabled" do
    trip = trips(:alpha_trip)
    trip.update!(disabled_sections: [ "menu" ])
    assert_not trip.section_enabled?("menu")
    assert trip.section_enabled?("notes")
  end

  test "rejects an unknown section key" do
    trip = trips(:alpha_trip)
    trip.disabled_sections = [ "unknown_section" ]
    assert_not trip.valid?
  end
end
