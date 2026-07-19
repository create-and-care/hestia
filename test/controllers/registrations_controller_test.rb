require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create signs up and redirects to onboarding" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: { user: {
        name: "Carol", email_address: "carol@example.com",
        password: "secret123", password_confirmation: "secret123"
      } }
    end

    assert_redirected_to onboarding_path
    assert cookies[:session_id]
  end

  test "create with invalid data re-renders the form" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: {
        name: "", email_address: "bad", password: "x", password_confirmation: "y"
      } }
    end

    assert_response :unprocessable_entity
  end

  # No test covers the `rate_limit` behavior itself here, matching Sessions#create
  # and Passwords#create (also untested for the same reason): the `store:` it
  # writes to is resolved from `Rails.cache` once, when the controller class
  # first loads — which happens long before any per-test override of
  # `Rails.cache` could take effect against the test environment's :null_store.
end
