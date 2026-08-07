require "test_helper"

class GlobalSearchTest < ActiveSupport::TestCase
  setup do
    @household = households(:alpha)
    @user = users(:one)
  end

  test "blank query returns no results" do
    assert_equal [], GlobalSearch.call(query: "", household: @household, user: @user)
    assert_equal [], GlobalSearch.call(query: "   ", household: @household, user: @user)
  end

  test "finds a matching record scoped to the household, without leaking another household's data" do
    results = GlobalSearch.call(query: "vaisselle", household: @household, user: @user)
    tasks_group = results.find { |g| g[:module_key] == "tasks" }

    assert tasks_group, "expected a tasks group in the results"
    assert_includes tasks_group[:records].map { |r| r[:label] }, "Faire la vaisselle"

    results = GlobalSearch.call(query: "Rapport", household: @household, user: @user)
    assert_nil results.find { |g| g[:module_key] == "tasks" }, "beta's task must not appear while scoped to alpha"
  end

  test "skips a module the household has disabled" do
    @household.update!(disabled_modules: [ "tasks" ])

    results = GlobalSearch.call(query: "vaisselle", household: @household, user: @user)
    assert_nil results.find { |g| g[:module_key] == "tasks" }
  end

  test "circles are searched by user membership, not by household" do
    results = GlobalSearch.call(query: "élargie", household: @household, user: @user)
    circles_group = results.find { |g| g[:module_key] == "circles" }

    assert circles_group, "expected user one's circle membership to be found regardless of the current household"
    assert_includes circles_group[:records].map { |r| r[:label] }, circles(:family).name

    results = GlobalSearch.call(query: "élargie", household: @household, user: users(:two))
    assert circles_group_for_two = results.find { |g| g[:module_key] == "circles" }
    assert_includes circles_group_for_two[:records].map { |r| r[:label] }, circles(:family).name
  end

  test "does not find a circle the user is not a member of" do
    results = GlobalSearch.call(query: "Autre cercle", household: @household, user: @user)
    assert_nil results.find { |g| g[:module_key] == "circles" }
  end

  test "matches a recipe by one of its tags" do
    recipe = recipes(:alpha_pancakes)
    recipe.update!(tags: [ "healthy", "quick" ])

    results = GlobalSearch.call(query: "healthy", household: @household, user: @user)
    recipes_group = results.find { |g| g[:module_key] == "recipes" }

    assert recipes_group, "expected a recipes group matched by tag"
    assert_includes recipes_group[:records].map { |r| r[:label] }, recipe.title
  end

  test "conversations are searched by participant, not merely by household" do
    results = GlobalSearch.call(query: "Organisation", household: @household, user: @user)
    messages_group = results.find { |g| g[:module_key] == "messages" }
    assert messages_group, "expected user one, a participant, to find their own conversation"

    results = GlobalSearch.call(query: "Organisation", household: @household, user: users(:two))
    assert_nil results.find { |g| g[:module_key] == "messages" },
      "a household member who never joined the conversation must not find it (nor its 404 on click)"
  end

  test "a conversation the user participates in from another household does not leak into the current household's search" do
    households(:beta).memberships.create!(user: @user, role: "member")
    conversations(:beta_chat).conversation_participants.create!(user: @user)

    results = GlobalSearch.call(query: "Chat Beta", household: @household, user: @user)
    assert_nil results.find { |g| g[:module_key] == "messages" },
      "being a participant of a conversation in a household the user ALSO belongs to must not surface it while viewing a different household"
  end

  test "finds a bottle and a wine cellar" do
    bottle_results = GlobalSearch.call(query: "margaux", household: @household, user: @user)
    bottle_group = bottle_results.find { |g| g[:module_key] == "wine_cellar" && g[:records].any? { |r| r[:label] == "Château Margaux" } }
    assert bottle_group, "expected a wine_cellar group matched by bottle name"

    cellar_results = GlobalSearch.call(query: wine_cellars(:alpha_reds).name, household: @household, user: @user)
    cellar_group = cellar_results.find { |g| g[:module_key] == "wine_cellar" && g[:records].any? { |r| r[:label] == wine_cellars(:alpha_reds).name } }
    assert cellar_group, "expected a wine_cellar group matched by cellar name"
  end

  test "finds a fridge item" do
    results = GlobalSearch.call(query: "yaourt", household: @household, user: @user)
    group = results.find { |g| g[:module_key] == "fridge" }

    assert group, "expected a fridge group"
    assert_includes group[:records].map { |r| r[:label] }, fridge_items(:alpha_yogurt).name
  end

  test "finds a free-text menu entry but not one already covered by the recipe search" do
    entry = meal_plan_entries(:alpha_dinner)
    household_entry = @household.meal_plan_entries.create!(on_date: Date.current, meal_type: "lunch", free_name: "Salade composée")

    results = GlobalSearch.call(query: "composée", household: @household, user: @user)
    group = results.find { |g| g[:module_key] == "menu" }
    assert group, "expected a menu group matched by free_name"
    assert_includes group[:records].map { |r| r[:label] }, household_entry.display_name

    results = GlobalSearch.call(query: entry.recipe.title, household: @household, user: @user)
    assert_nil results.find { |g| g[:module_key] == "menu" }, "a recipe-backed entry should surface via the recipe search, not menu"
  end

  test "finds a waste collection series by its translated type label" do
    results = GlobalSearch.call(query: "ordures", household: @household, user: @user)
    group = results.find { |g| g[:module_key] == "waste" }

    assert group, "expected a waste group matched by waste_type"
    assert_includes group[:records].map { |r| r[:label] }, I18n.t("waste.types.ordures")
  end

  test "finds a plant and a pool under the outdoor module" do
    results = GlobalSearch.call(query: "Rosier", household: @household, user: @user)
    plant_group = results.find { |g| g[:module_key] == "outdoor" && g[:records].any? { |r| r[:label] == "Rosier" } }
    assert plant_group, "expected an outdoor group matched by plant name"

    results = GlobalSearch.call(query: "Piscine principale", household: @household, user: @user)
    pool_group = results.find { |g| g[:module_key] == "outdoor" && g[:records].any? { |r| r[:label] == "Piscine principale" } }
    assert pool_group, "expected an outdoor group matched by pool name"
  end

  test "excludes pools when the household has turned off the Pool switch, but keeps plants" do
    @household.update!(pool_enabled: false)

    results = GlobalSearch.call(query: "Piscine principale", household: @household, user: @user)
    assert_nil results.find { |g| g[:module_key] == "outdoor" }, "a disabled Pool switch must hide pool results"

    results = GlobalSearch.call(query: "Rosier", household: @household, user: @user)
    plant_group = results.find { |g| g[:module_key] == "outdoor" && g[:records].any? { |r| r[:label] == "Rosier" } }
    assert plant_group, "plants must still be searchable when only Pool is disabled"
  end

  test "finds a workout entry scoped to the searching user only, never another household member's" do
    @user.workout_entries.create!(exercise: "Squats bulgares", done_on: Date.current)
    users(:two).workout_entries.create!(exercise: "Squats sautés", done_on: Date.current)

    results = GlobalSearch.call(query: "squats", household: @household, user: @user)
    group = results.find { |g| g[:module_key] == "wellbeing" }

    assert group, "expected a wellbeing group for the searching user's own workout"
    labels = group[:records].map { |r| r[:label] }
    assert_includes labels, "Squats bulgares"
    assert_not_includes labels, "Squats sautés", "another user's private workout must never leak into this search"
  end
end
