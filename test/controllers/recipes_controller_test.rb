require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get recipes_path
    assert_redirected_to new_session_path
  end

  test "index shows only the household's recipes" do
    get recipes_path
    assert_response :success
    assert_includes @response.body, "Pancakes"
    assert_not_includes @response.body, "Soupe"
  end

  test "search filters the recipes" do
    get recipes_path(q: "panc")
    assert_response :success
    assert_includes @response.body, "Pancakes"
  end

  test "show renders the ingredients" do
    get recipe_path(recipes(:alpha_pancakes))
    assert_response :success
    assert_includes @response.body, "farine"
  end

  test "show renders a quick meal-planning form" do
    recipe = recipes(:alpha_pancakes)
    get recipe_path(recipe)
    assert_response :success
    assert_select "form[action=?]", meal_plan_entries_path do
      assert_select "input[name='meal_plan_entry[recipe_id]'][value=?]", recipe.id.to_s
    end
  end

  test "planning a meal from the recipe show page creates a menu entry" do
    recipe = recipes(:alpha_pancakes)
    assert_difference -> { households(:alpha).meal_plan_entries.count }, 1 do
      post meal_plan_entries_path, params: {
        meal_plan_entry: { on_date: Date.current, meal_type: "dinner", recipe_id: recipe.id }
      }
    end
    assert_equal recipe, MealPlanEntry.order(:id).last.recipe
  end

  test "create builds ingredients, steps and tags from text areas" do
    assert_difference -> { households(:alpha).recipes.count }, 1 do
      post recipes_path, params: { recipe: {
        title: "Crêpes", category: "Dessert", tags_text: "rapide, sucré",
        ingredients_text: "250 g farine\n2 oeufs", steps_text: "Mélanger\nCuire"
      } }
    end
    recipe = Recipe.find_by!(title: "Crêpes")
    assert_equal 2, recipe.recipe_ingredients.count
    assert_equal 2, recipe.recipe_steps.count
    assert_equal %w[rapide sucré], recipe.tags
    assert_redirected_to recipe
  end

  test "update replaces the children" do
    recipe = recipes(:alpha_pancakes)
    patch recipe_path(recipe), params: { recipe: { title: "Pancakes US", ingredients_text: "farine", steps_text: "Cuire" } }
    assert_redirected_to recipe
    assert_equal "Pancakes US", recipe.reload.title
    assert_equal 1, recipe.recipe_ingredients.count
  end

  test "destroy" do
    recipe = recipes(:alpha_pancakes)
    delete recipe_path(recipe)
    assert_redirected_to recipes_path
    assert_not Recipe.exists?(recipe.id)
  end

  test "cook mode renders" do
    get cook_recipe_path(recipes(:alpha_pancakes))
    assert_response :success
  end

  test "add_to_shopping_list exports the ingredients" do
    recipe = recipes(:alpha_pancakes)
    assert_difference -> { ShoppingListItem.count }, recipe.recipe_ingredients.count do
      post add_to_shopping_list_recipe_path(recipe)
    end
    assert_redirected_to recipe
  end

  test "import with a blank url re-renders the form" do
    post import_recipes_path, params: { url: "" }
    assert_response :unprocessable_entity
  end

  test "cannot access another household's recipe" do
    get recipe_path(recipes(:beta_soup))
    assert_response :not_found
  end
end
