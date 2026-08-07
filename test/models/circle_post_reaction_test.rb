require "test_helper"

class CirclePostReactionTest < ActiveSupport::TestCase
  test "requires an emoji" do
    reaction = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:two))
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], error_message(:blank)
  end

  test "rejects an emoji outside the allowed list" do
    reaction = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:two), emoji: "🐍")
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], error_message(:inclusion)
  end

  test "belongs to a circle_post and a user" do
    reaction = CirclePostReaction.new(emoji: "❤️")
    assert_not reaction.valid?
    assert_includes reaction.errors[:circle_post], error_message(:required)
    assert_includes reaction.errors[:user], error_message(:required)
  end

  test "a user cannot react to the same post twice" do
    circle_posts(:family_post).circle_post_reactions.create!(user: users(:two), emoji: "👍")
    duplicate = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:two), emoji: "❤️")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], error_message(:taken)
  end

  test "different users can each react to the same post" do
    circle_posts(:family_post).circle_post_reactions.create!(user: users(:two), emoji: "👍")
    reaction = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:one), emoji: "❤️")

    assert reaction.valid?
  end
end
