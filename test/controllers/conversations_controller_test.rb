require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get conversations_path
    assert_redirected_to new_session_path
  end

  test "index shows conversations the user participates in" do
    get conversations_path
    assert_response :success
    assert_includes @response.body, "Organisation"
    assert_not_includes @response.body, "Chat Beta"
  end

  test "show renders the messages" do
    get conversation_path(conversations(:alpha_chat))
    assert_response :success
    assert_includes @response.body, "Bonjour la famille"
    assert_select "turbo-cable-stream-source"
  end

  test "create adds the current user as a participant and ignores users outside the household" do
    assert_difference -> { households(:alpha).conversations.count }, 1 do
      post conversations_path, params: { conversation: { name: "Vacances" }, participant_ids: [ users(:two).id ] }
    end
    conversation = Conversation.find_by!(name: "Vacances")
    assert_equal [ users(:one) ], conversation.participants.to_a
  end

  test "cannot access a conversation from another household" do
    get conversation_path(conversations(:beta_chat))
    assert_response :not_found
  end
end
