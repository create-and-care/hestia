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

    assert_difference [ "Note.count", "Task.count", "ShoppingList.count", "Address.count" ], -1 do
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
end
