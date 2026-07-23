require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "edit requires authentication" do
    get edit_account_path
    assert_redirected_to new_session_path
  end

  test "edit renders the current user's info" do
    sign_in_as(users(:one))

    get edit_account_path
    assert_response :success
    assert_select "input[name='user[name]'][value=?]", users(:one).name
  end

  test "update changes the name and email with the correct current password" do
    user = users(:one)
    sign_in_as(user)

    patch account_path, params: { user: { name: "New Name", email_address: "newmail@example.com", current_password: "password" } }

    assert_redirected_to household_path(households(:alpha), tab: "members")
    assert_equal "New Name", user.reload.name
    assert_equal "newmail@example.com", user.email_address
  end

  test "update rejects the wrong current password without changing anything" do
    user = users(:one)
    sign_in_as(user)
    original_name = user.name

    patch account_path, params: { user: { name: "New Name", current_password: "wrongpassword" } }

    assert_response :unprocessable_entity
    assert_equal original_name, user.reload.name
  end

  test "update changes the password when a new one is given" do
    user = users(:one)
    sign_in_as(user)

    patch account_path, params: { user: { password: "newpassword123", password_confirmation: "newpassword123", current_password: "password" } }

    assert_redirected_to household_path(households(:alpha), tab: "members")
    assert user.reload.authenticate("newpassword123")
  end

  test "update keeps the current password when the password fields are left blank" do
    user = users(:one)
    sign_in_as(user)

    patch account_path, params: { user: { name: "New Name", current_password: "password" } }

    assert_redirected_to household_path(households(:alpha), tab: "members")
    assert user.reload.authenticate("password")
  end
end
