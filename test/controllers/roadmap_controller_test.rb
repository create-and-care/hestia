require "test_helper"

class RoadmapControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get roadmap_path
    assert_redirected_to new_session_path
  end

  test "renders without an active household" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get roadmap_path
    assert_response :success
    assert_includes @response.body, "Phase 1 — Foundation"
    assert_includes @response.body, "Hest.AI (Phase 3)"
  end

  test "is reachable from onboarding" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get onboarding_path
    assert_select "a[href=?]", roadmap_path
  end
end
