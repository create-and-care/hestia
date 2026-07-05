require "test_helper"

class RoadmapControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get roadmap_path
    assert_redirected_to new_session_path
  end

  test "shows the roadmap for a user without a household" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get roadmap_path
    assert_response :success
    assert_select "h1", text: "🗺️ Roadmap"
  end

  test "shows the roadmap for a household member" do
    sign_in_as(users(:one))

    get roadmap_path
    assert_response :success
  end
end
