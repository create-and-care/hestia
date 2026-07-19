require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "redirects to onboarding when the user has no household" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get root_path
    assert_redirected_to onboarding_path
  end

  test "shows the active household and its members for a member" do
    sign_in_as(users(:one))

    get root_path
    assert_response :success
    assert_select "h1", text: households(:alpha).name
    assert_select "code", text: households(:alpha).invite_code
  end

  test "two households do not share members" do
    assert_not_includes households(:alpha).users, users(:two)
    assert_not_includes households(:beta).users, users(:one)
  end

  test "surfaces a vehicle with an urgent or expired inspection" do
    sign_in_as(users(:one))
    households(:alpha).vehicles.create!(name: "Urgent Car", inspection_expires_on: 10.days.from_now.to_date)

    get root_path

    assert_response :success
    assert_includes @response.body, "Urgent Car"
  end

  test "does not surface a vehicle with an up-to-date inspection" do
    sign_in_as(users(:one))
    households(:alpha).vehicles.create!(name: "Fine Car", inspection_expires_on: 200.days.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Fine Car"
  end

  test "the sidebar hides a module the household has disabled" do
    households(:alpha).update!(disabled_modules: [ "shopping" ])
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_no_match %r{href="/shopping_lists"}, @response.body
    assert_match %r{href="/fridge"}, @response.body
  end

  test "surfaces a fridge item close to expiring" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Yaourts", location: "refrigerateur", expires_on: 1.day.from_now.to_date)

    get root_path

    assert_response :success
    assert_includes @response.body, "Yaourts"
  end

  test "does not surface a fridge item far from expiring" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Conserve", location: "garde_manger", expires_on: 200.days.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Conserve"
  end

  test "hides fridge items when the fridge module is disabled" do
    households(:alpha).update!(disabled_modules: [ "fridge" ])
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Yaourts", location: "refrigerateur", expires_on: 1.day.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Yaourts"
  end

  test "surfaces an overdue task" do
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Appeler le plombier", due_on: 3.days.ago.to_date, done: false)

    get root_path

    assert_response :success
    assert_includes @response.body, "Appeler le plombier"
  end

  test "does not surface a completed overdue task" do
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Déjà fait", due_on: 3.days.ago.to_date, done: true)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Déjà fait"
  end

  test "hides overdue tasks when the tasks module is disabled" do
    households(:alpha).update!(disabled_modules: [ "tasks" ])
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Appeler le plombier", due_on: 3.days.ago.to_date, done: false)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Appeler le plombier"
  end

  test "surfaces a birthday within the next week" do
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Mamie", born_on: 3.days.from_now.to_date - 80.years)

    get root_path

    assert_response :success
    assert_includes @response.body, "Mamie"
  end

  test "does not surface a birthday far in the future" do
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Lointain", born_on: (Date.current + 6.months) - 30.years)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Lointain"
  end

  test "hides birthdays when the birthdays module is disabled" do
    households(:alpha).update!(disabled_modules: [ "birthdays" ])
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Mamie", born_on: 3.days.from_now.to_date - 80.years)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Mamie"
  end

  test "surfaces an upcoming calendar event" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Anniversaire", starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour)

    get root_path

    assert_response :success
    assert_includes @response.body, "Anniversaire"
  end

  test "does not surface a past calendar event" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Passé", starts_at: 2.days.ago, ends_at: 2.days.ago + 1.hour)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Passé"
  end

  test "hides upcoming events when the calendar module is disabled" do
    households(:alpha).update!(disabled_modules: [ "calendar" ])
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Anniversaire", starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Anniversaire"
  end

  test "surfaces a recipe suggestion built from fridge contents" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Farine", location: "garde_manger")
    recipe = households(:alpha).recipes.create!(title: "Crêpes")
    recipe.recipe_ingredients.create!(name: "Farine")

    get root_path

    assert_response :success
    assert_includes @response.body, "Crêpes"
  end

  test "hides recipe suggestions when the recipes module is disabled" do
    households(:alpha).update!(disabled_modules: [ "recipes" ])
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Farine", location: "garde_manger")
    recipe = households(:alpha).recipes.create!(title: "Crêpes")
    recipe.recipe_ingredients.create!(name: "Farine")

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Crêpes"
  end
end
