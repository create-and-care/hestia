require "test_helper"

class MenuControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get menu_path
    assert_redirected_to new_session_path
  end

  test "show renders the week" do
    get menu_path
    assert_response :success
  end

  test "show flags a day missing a required meal type" do
    households(:alpha).update!(required_meal_types: %w[lunch dinner])

    get menu_path

    assert_response :success
    assert_includes @response.body, "Missing meal"
  end

  test "show does not flag a day once all required meals are planned" do
    households(:alpha).update!(required_meal_types: %w[dinner])
    monday = Date.current.beginning_of_week
    # alpha_dinner fixture already covers Tuesday; fill in the other six days.
    (monday..monday + 6.days).each do |day|
      next if day == meal_plan_entries(:alpha_dinner).on_date
      households(:alpha).meal_plan_entries.create!(on_date: day, meal_type: "dinner", free_name: "Pâtes")
    end

    get menu_path(week: monday)

    assert_response :success
    assert_not_includes @response.body, "Missing meal"
  end

  test "create a meal from a recipe" do
    assert_difference -> { households(:alpha).meal_plan_entries.count }, 1 do
      post meal_plan_entries_path, params: { meal_plan_entry: { on_date: Date.current, meal_type: "lunch", recipe_id: recipes(:alpha_pancakes).id } }
    end
    assert_response :redirect
  end

  test "create a free-name meal" do
    assert_difference -> { households(:alpha).meal_plan_entries.count }, 1 do
      post meal_plan_entries_path, params: { meal_plan_entry: { on_date: Date.current, meal_type: "dinner", free_name: "Restes" } }
    end
  end

  test "ignores a recipe from another household" do
    post meal_plan_entries_path, params: { meal_plan_entry: { on_date: Date.current, meal_type: "dinner", free_name: "X", recipe_id: recipes(:beta_soup).id } }
    assert_nil MealPlanEntry.find_by(free_name: "X").recipe_id
  end

  test "destroy" do
    entry = meal_plan_entries(:alpha_dinner)
    delete meal_plan_entry_path(entry)
    assert_not MealPlanEntry.exists?(entry.id)
  end

  test "cannot touch another household's entry" do
    delete meal_plan_entry_path(meal_plan_entries(:beta_lunch))
    assert_response :not_found
  end

  test "does not show trip-scoped meals in the general weekly view" do
    trip = trips(:alpha_trip)
    monday = Date.current.beginning_of_week
    households(:alpha).meal_plan_entries.create!(on_date: monday, meal_type: "lunch", free_name: "Pique-nique voyage", trip: trip)

    get menu_path(week: monday)

    assert_response :success
    assert_not_includes @response.body, "Pique-nique voyage"
  end
end
