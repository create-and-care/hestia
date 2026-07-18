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

  test "index defaults to card view and remembers list view across requests" do
    get recipes_path
    assert_response :success

    get recipes_path(view: "list")
    assert_response :success

    get recipes_path # no explicit view param this time
    assert_response :success
    assert_select "#recipes.divide-y"
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

  test "add_to_shopping_list is idempotent and links to the shopping list when already added" do
    recipe = recipes(:alpha_pancakes)
    post add_to_shopping_list_recipe_path(recipe)
    list = households(:alpha).shopping_lists.order(:created_at).first

    assert_no_difference -> { ShoppingListItem.count } do
      post add_to_shopping_list_recipe_path(recipe)
    end
    assert_redirected_to recipe
    follow_redirect!
    assert_includes @response.body, "already on the shopping list"
    assert_select "a[href=?]", shopping_list_path(list)
  end

  test "import with a blank url re-renders the form" do
    post import_recipes_path, params: { url: "" }
    assert_response :unprocessable_entity
  end

  test "cannot access another household's recipe" do
    get recipe_path(recipes(:beta_soup))
    assert_response :not_found
  end

  test "filters by category" do
    households(:alpha).recipes.create!(title: "Soupe froide", category: "Entrée")
    get recipes_path(category: "Entrée")
    assert_includes @response.body, "Soupe froide"
    assert_not_includes @response.body, "Pancakes"
  end

  test "paginates when there are more recipes than the page size" do
    households(:alpha).recipes.destroy_all
    (RecipesController::PER_PAGE + 1).times { |i| households(:alpha).recipes.create!(title: "Recette #{'%02d' % i}") }

    get recipes_path
    assert_includes @response.body, "Recette 00"
    assert_not_includes @response.body, "Recette #{'%02d' % RecipesController::PER_PAGE}"

    get recipes_path(page: 2)
    assert_includes @response.body, "Recette #{'%02d' % RecipesController::PER_PAGE}"
  end

  test "create attaches an optional photo" do
    photo = fixture_file_upload("sample.png", "image/png")
    post recipes_path, params: { recipe: { title: "Gâteau", photo: photo } }
    assert Recipe.find_by!(title: "Gâteau").photo.attached?
  end

  test "cook mode does not render the app sidebar" do
    get cook_recipe_path(recipes(:alpha_pancakes))
    assert_response :success
    assert_select "[data-controller='sidebar']", false
    assert_select "[data-controller='wake-lock']"
  end

  test "link_note links an existing unlinked note to the recipe" do
    recipe = recipes(:alpha_pancakes)
    note = notes(:alpha_idea)
    post link_note_recipe_path(recipe), params: { note_id: note.id }
    assert_equal recipe, note.reload.recipe
  end

  test "link_bottle links an existing unlinked bottle to the recipe" do
    recipe = recipes(:alpha_pancakes)
    bottle = bottles(:alpha_bordeaux)
    post link_bottle_recipe_path(recipe), params: { bottle_id: bottle.id }
    assert_equal recipe, bottle.reload.recipe
  end

  test "cannot link another household's note" do
    recipe = recipes(:alpha_pancakes)
    post link_note_recipe_path(recipe), params: { note_id: notes(:beta_note).id }
    assert_response :not_found
  end
end
