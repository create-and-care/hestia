require "test_helper"

class ConversationParticipantTest < ActiveSupport::TestCase
  test "requires a unique user per conversation" do
    duplicate = ConversationParticipant.new(conversation: conversations(:alpha_chat), user: users(:one))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], error_message(:taken)
  end

  test "the same user can participate in conversations from different households" do
    # Household membership is not enforced at this level: only actual
    # participation matters here. The stricter access boundary (a household
    # member who never joined the conversation cannot see it) is enforced by
    # ConversationsController#accessible_conversations, not by this model.
    participant = ConversationParticipant.new(conversation: conversations(:beta_chat), user: users(:one))
    assert participant.valid?
  end

  test "belongs to a conversation and a user" do
    participant = conversation_participants(:alpha_chat_one)
    assert_equal conversations(:alpha_chat), participant.conversation
    assert_equal users(:one), participant.user
  end
end
