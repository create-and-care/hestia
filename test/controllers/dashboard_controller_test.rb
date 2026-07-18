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
end
