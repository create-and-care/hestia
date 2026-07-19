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

  test "unread_for? is true when the participant has never read the conversation" do
    conversation = conversations(:alpha_chat)
    assert conversation.unread_for?(users(:one))
  end

  test "unread_for? is false once the participant has read past the last message" do
    conversation = conversations(:alpha_chat)
    conversation.conversation_participants.find_by(user: users(:one)).update!(last_read_at: Time.current)
    assert_not conversation.unread_for?(users(:one))
  end

  test "unread_for? is false for a non-participant" do
    assert_not conversations(:alpha_chat).unread_for?(users(:two))
  end

  test "unread_for scope returns conversations with messages newer than last_read_at" do
    conversation = conversations(:alpha_chat)
    assert_includes Conversation.unread_for(users(:one)), conversation

    conversation.conversation_participants.find_by(user: users(:one)).update!(last_read_at: Time.current)
    assert_not_includes Conversation.unread_for(users(:one)), conversation
  end

  test "can be linked to a task, shopping list or calendar event via polymorphic subject" do
    task = households(:alpha).tasks.create!(title: "Organiser la fête")
    conversation = households(:alpha).conversations.create!(name: "Organiser la fête", subject: task)
    assert_equal task, conversation.subject
    assert_equal conversation, task.reload.conversation
  end

  test "subject is nullified (not destroyed) when the linked task is destroyed" do
    task = households(:alpha).tasks.create!(title: "Organiser la fête")
    conversation = households(:alpha).conversations.create!(name: "Organiser la fête", subject: task)
    task.destroy
    assert_nil conversation.reload.subject
  end
end
