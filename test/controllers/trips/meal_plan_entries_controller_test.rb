require "test_helper"

class Trips::MealPlanEntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create responds with a turbo stream" do
    trip = trips(:alpha_trip)
    assert_difference -> { trip.meal_plan_entries.count }, 1 do
      post trip_meal_plan_entries_path(trip), params: { meal_plan_entry: { on_date: Date.current, meal_type: "dinner", free_name: "Pizza" } }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create without a recipe or free name flashes an alert" do
    trip = trips(:alpha_trip)
    assert_no_difference -> { trip.meal_plan_entries.count } do
      post trip_meal_plan_entries_path(trip), params: { meal_plan_entry: { on_date: Date.current, meal_type: "dinner" } }
    end
    assert_redirected_to trip
  end

  test "destroy responds with a turbo stream" do
    trip = trips(:alpha_trip)
    entry = trip.meal_plan_entries.create!(household: households(:alpha), on_date: Date.current, meal_type: "dinner", free_name: "Pizza")
    delete trip_meal_plan_entry_path(trip, entry), as: :turbo_stream
    assert_response :success
    assert_not MealPlanEntry.exists?(entry.id)
  end

  test "cannot create a meal on another household's trip" do
    trip = trips(:beta_trip)
    post trip_meal_plan_entries_path(trip), params: { meal_plan_entry: { on_date: Date.current, meal_type: "dinner", free_name: "X" } }
    assert_response :not_found
  end
end
