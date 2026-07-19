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

  test "a blank message does not persist and surfaces an error instead of failing silently" do
    conversation = conversations(:alpha_chat)
    assert_no_difference -> { conversation.messages.count } do
      post conversation_messages_path(conversation), params: { message: { content: "" } }
    end
    assert_redirected_to conversation
    assert_equal "Content can't be blank", flash[:alert]
  end

  test "a blank message via turbo_stream re-renders the composer with the error, preserving nothing sent" do
    conversation = conversations(:alpha_chat)
    post conversation_messages_path(conversation), params: { message: { content: "" } }, as: :turbo_stream
    assert_response :success
    assert_includes @response.body, "can&#39;t be blank"
  end

  test "message content is rendered through Ui::TextareaComponent so it supports multiple lines" do
    get conversation_path(conversations(:alpha_chat))
    assert_select "textarea#message_content"
  end
end
