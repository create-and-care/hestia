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

  test "the sidebar hides a module the household has disabled" do
    households(:alpha).update!(disabled_modules: [ "shopping" ])
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_no_match %r{href="/shopping_lists"}, @response.body
    assert_match %r{href="/fridge"}, @response.body
  end
end
