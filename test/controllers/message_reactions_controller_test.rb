require "test_helper"

class MessageReactionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post react_message_path(messages(:alpha_hello), emoji: "❤️")
    assert_redirected_to new_session_path
  end

  test "create adds a reaction from the current user" do
    message = messages(:alpha_hello)
    assert_difference -> { message.message_reactions.count }, 1 do
      post react_message_path(message, emoji: "❤️")
    end
    assert_redirected_to message.conversation
    reaction = message.message_reactions.find_by(user: users(:one))
    assert_equal "❤️", reaction.emoji
  end

  test "create updates the existing reaction instead of duplicating" do
    message = messages(:alpha_hello)
    message.message_reactions.create!(user: users(:one), emoji: "👍")

    assert_no_difference -> { message.message_reactions.count } do
      post react_message_path(message, emoji: "❤️")
    end
    assert_equal "❤️", message.message_reactions.find_by(user: users(:one)).emoji
  end

  test "destroy removes the current user's reaction" do
    message = messages(:alpha_hello)
    message.message_reactions.create!(user: users(:one), emoji: "👍")

    assert_difference -> { message.message_reactions.count }, -1 do
      delete unreact_message_path(message)
    end
  end

  # Access is by conversation participation, never by household alone.
  test "cannot react to a message in a conversation the user does not participate in" do
    other_message = conversations(:beta_chat).messages.create!(author: users(:two), content: "Message Beta")
    assert_no_difference -> { MessageReaction.count } do
      post react_message_path(other_message, emoji: "❤️")
    end
    assert_response :not_found
  end

  test "create responds with a turbo stream replacing the message in place" do
    message = messages(:alpha_hello)
    post react_message_path(message, emoji: "❤️"), as: :turbo_stream
    assert_turbo_stream action: "replace", target: dom_id(message)
  end

  test "destroy responds with a turbo stream replacing the message in place" do
    message = messages(:alpha_hello)
    message.message_reactions.create!(user: users(:one), emoji: "👍")

    delete unreact_message_path(message), as: :turbo_stream
    assert_turbo_stream action: "replace", target: dom_id(message)
  end

  test "a disallowed emoji is not persisted" do
    message = messages(:alpha_hello)
    assert_no_difference -> { message.message_reactions.count } do
      post react_message_path(message, emoji: "🐍")
    end
  end
end
