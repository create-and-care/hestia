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
end
