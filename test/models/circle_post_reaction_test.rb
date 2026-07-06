require "test_helper"

class CirclePostReactionTest < ActiveSupport::TestCase
  test "requires an emoji" do
    reaction = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:two))
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "can't be blank"
  end

  test "belongs to a circle_post and a user" do
    reaction = CirclePostReaction.new(emoji: "❤️")
    assert_not reaction.valid?
    assert_includes reaction.errors[:circle_post], "must exist"
    assert_includes reaction.errors[:user], "must exist"
  end

  test "a user cannot react to the same post twice" do
    circle_posts(:family_post).circle_post_reactions.create!(user: users(:two), emoji: "👍")
    duplicate = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:two), emoji: "❤️")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "different users can each react to the same post" do
    circle_posts(:family_post).circle_post_reactions.create!(user: users(:two), emoji: "👍")
    reaction = CirclePostReaction.new(circle_post: circle_posts(:family_post), user: users(:one), emoji: "❤️")

    assert reaction.valid?
  end
end
