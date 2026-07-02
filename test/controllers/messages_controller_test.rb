require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "post a message to an accessible conversation" do
    conversation = conversations(:alpha_chat)
    assert_difference -> { conversation.messages.count }, 1 do
      post conversation_messages_path(conversation), params: { message: { content: "Salut" } }, as: :turbo_stream
    end
    assert_response :success
    assert_equal users(:one), conversation.messages.last.author
  end

  test "cannot post to a conversation the user cannot access" do
    assert_no_difference -> { Message.count } do
      post conversation_messages_path(conversations(:beta_chat)), params: { message: { content: "Intrus" } }
    end
    assert_response :not_found
  end
end
