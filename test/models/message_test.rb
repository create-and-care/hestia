require "test_helper"

class MessageTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "requires content" do
    message = conversations(:alpha_chat).messages.build(author: users(:one))
    assert_not message.valid?
    message.content = "Salut"
    assert message.valid?
  end

  test "belongs to a conversation and an author" do
    message = messages(:alpha_hello)
    assert_equal conversations(:alpha_chat), message.conversation
    assert_equal users(:one), message.author
  end

  test "chronological scope orders oldest first" do
    older = Message.create!(conversation: conversations(:alpha_chat), author: users(:one), content: "Premier", created_at: 2.days.ago)
    newer = Message.create!(conversation: conversations(:alpha_chat), author: users(:one), content: "Second", created_at: 1.day.ago)
    assert_equal [ older, newer ], Message.where(id: [ older.id, newer.id ]).chronological.to_a
  end

  test "creating a message broadcasts a conversation-list update to every participant" do
    conversation = conversations(:alpha_chat)
    conversation.conversation_participants.create!(user: users(:two))

    assert_enqueued_with(job: Turbo::Streams::ActionBroadcastJob) do
      conversation.messages.create!(author: users(:one), content: "Salut")
    end
  end
end
