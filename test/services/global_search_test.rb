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
end
