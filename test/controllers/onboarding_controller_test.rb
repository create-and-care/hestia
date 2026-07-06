require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get onboarding_path
    assert_redirected_to new_session_path
  end

  test "renders the create-or-join choice when the user has no household" do
    user = User.create!(name: "Solo", email_address: "solo@example.com", password: "password")
    sign_in_as(user)

    get onboarding_path
    assert_response :success
  end

  test "redirects to root when the user already belongs to a household" do
    sign_in_as(users(:one))

    get onboarding_path
    assert_redirected_to root_path
  end
end
