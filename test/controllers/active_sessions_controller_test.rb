require "test_helper"

class ActiveSessionsControllerTest < ActionDispatch::IntegrationTest
  test "revoking another session destroys it and stays signed in" do
    sign_in_as(users(:one))
    other_session = users(:one).sessions.create!(user_agent: "Other Device")

    delete active_session_path(other_session)

    assert_redirected_to household_path(households(:alpha))
    assert_not Session.exists?(other_session.id)
    get household_path(households(:alpha))
    assert_response :success
  end

  test "revoking the current session signs the user out" do
    sign_in_as(users(:one))
    current = Current.session

    delete active_session_path(current)

    assert_redirected_to new_session_path
    assert_not Session.exists?(current.id)
  end

  test "a user cannot revoke another user's session" do
    session = users(:two).sessions.create!
    sign_in_as(users(:one))

    delete active_session_path(session)

    assert_response :not_found
    assert Session.exists?(session.id)
  end
end
