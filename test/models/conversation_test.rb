require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "requires a name" do
    conversation = households(:alpha).conversations.build
    assert_not conversation.valid?
    conversation.name = "Test"
    assert conversation.valid?
  end

  test "participants are the users through conversation_participants" do
    assert_equal [ users(:one) ], conversations(:alpha_chat).participants.to_a
  end

  test "destroying a conversation destroys its participants and messages" do
    conversation = conversations(:alpha_chat)
    assert_difference -> { ConversationParticipant.count }, -1 do
      assert_difference -> { Message.count }, -1 do
        conversation.destroy
      end
    end
  end

  test "ordered scope orders by most recently updated" do
    older = Conversation.create!(household: households(:alpha), name: "Older", updated_at: 2.days.ago)
    newer = Conversation.create!(household: households(:alpha), name: "Newer", updated_at: 1.day.ago)
    assert_equal [ newer, older ], Conversation.where(id: [ older.id, newer.id ]).ordered.to_a
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).conversations, conversations(:beta_chat)
  end
end
