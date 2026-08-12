require "test_helper"

class MessageReactionTest < ActiveSupport::TestCase
  test "requires an emoji" do
    reaction = MessageReaction.new(message: messages(:alpha_hello), user: users(:two))
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], error_message(:blank)
  end

  test "rejects an emoji outside the allowed list" do
    reaction = MessageReaction.new(message: messages(:alpha_hello), user: users(:two), emoji: "🐍")
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], error_message(:inclusion)
  end

  test "belongs to a message and a user" do
    reaction = MessageReaction.new(emoji: "❤️")
    assert_not reaction.valid?
    assert_includes reaction.errors[:message], error_message(:required)
    assert_includes reaction.errors[:user], error_message(:required)
  end

  test "a user cannot react to the same message twice" do
    messages(:alpha_hello).message_reactions.create!(user: users(:two), emoji: "👍")
    duplicate = MessageReaction.new(message: messages(:alpha_hello), user: users(:two), emoji: "❤️")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], error_message(:taken)
  end

  test "different users can each react to the same message" do
    messages(:alpha_hello).message_reactions.create!(user: users(:two), emoji: "👍")
    reaction = MessageReaction.new(message: messages(:alpha_hello), user: users(:one), emoji: "❤️")

    assert reaction.valid?
  end

  test "destroying a conversation with a reacted message does not raise" do
    messages(:alpha_hello).message_reactions.create!(user: users(:two), emoji: "👍")

    assert_nothing_raised { conversations(:alpha_chat).destroy! }
  end
end
