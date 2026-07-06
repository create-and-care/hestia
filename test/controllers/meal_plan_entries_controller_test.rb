require "test_helper"

class MealPlanEntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create with a recipe" do
    assert_difference -> { households(:alpha).meal_plan_entries.count }, 1 do
      post meal_plan_entries_path, params: {
        meal_plan_entry: { on_date: Date.current, meal_type: "lunch", recipe_id: recipes(:alpha_pancakes).id }
      }
    end
    entry = MealPlanEntry.order(:id).last
    assert_redirected_to menu_path(week: entry.on_date)
    assert_equal recipes(:alpha_pancakes), entry.recipe
  end

  test "create with a free name and no recipe" do
    assert_difference -> { households(:alpha).meal_plan_entries.count }, 1 do
      post meal_plan_entries_path, params: {
        meal_plan_entry: { on_date: Date.current, meal_type: "snack", free_name: "Fruits" }
      }
    end
    assert_equal "Fruits", MealPlanEntry.order(:id).last.free_name
  end

  test "ignores a recipe from another household" do
    post meal_plan_entries_path, params: {
      meal_plan_entry: { on_date: Date.current, meal_type: "lunch", recipe_id: recipes(:beta_soup).id, free_name: "Repas" }
    }
    assert_nil MealPlanEntry.order(:id).last.recipe_id
  end

  test "update" do
    entry = meal_plan_entries(:alpha_dinner)
    patch meal_plan_entry_path(entry), params: { meal_plan_entry: { meal_type: "lunch" } }
    assert_redirected_to menu_path(week: entry.on_date)
    assert_equal "lunch", entry.reload.meal_type
  end

  test "destroy" do
    entry = meal_plan_entries(:alpha_dinner)
    assert_difference -> { MealPlanEntry.count }, -1 do
      delete meal_plan_entry_path(entry)
    end
    assert_redirected_to menu_path(week: entry.on_date)
  end

  test "cannot update another household's entry" do
    patch meal_plan_entry_path(meal_plan_entries(:beta_lunch)), params: { meal_plan_entry: { meal_type: "dinner" } }
    assert_response :not_found
  end

  test "cannot destroy another household's entry" do
    assert_no_difference -> { MealPlanEntry.count } do
      delete meal_plan_entry_path(meal_plan_entries(:beta_lunch))
    end
    assert_response :not_found
  end
end
