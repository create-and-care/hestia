require "test_helper"

class CirclePostTest < ActiveSupport::TestCase
  test "requires a body" do
    post = CirclePost.new(circle: circles(:family), author: users(:one))
    assert_not post.valid?
    assert_includes post.errors[:body], error_message(:blank)
  end

  test "belongs to a circle and an author" do
    post = CirclePost.new(body: "Coucou")
    assert_not post.valid?
    assert_includes post.errors[:circle], error_message(:required)
    assert_includes post.errors[:author], error_message(:required)
  end

  test "destroying a post destroys its reactions" do
    post = circle_posts(:family_post)
    post.circle_post_reactions.create!(user: users(:two), emoji: "❤️")

    assert_difference -> { CirclePostReaction.count }, -1 do
      post.destroy
    end
  end

  test "chronological orders from newest to oldest" do
    circle = Circle.create!(name: "Ordre test")
    older = circle.circle_posts.create!(author: users(:one), body: "Ancien", created_at: 2.days.ago)
    newer = circle.circle_posts.create!(author: users(:one), body: "Nouveau", created_at: Time.current)

    assert_equal [ newer, older ], circle.circle_posts.chronological.to_a
  end

  test "deletable_by? the author" do
    post = circle_posts(:family_post) # authored by users(:one)
    assert post.deletable_by?(users(:one))
  end

  test "deletable_by? a circle admin who is not the author" do
    other_post = circles(:family).circle_posts.create!(author: users(:two), body: "Autre auteur")
    assert other_post.deletable_by?(users(:one)) # users(:one) is the family admin
  end

  test "not deletable_by? a plain member who is neither author nor admin" do
    post = circle_posts(:family_post) # authored by users(:one), the family admin
    assert_not post.deletable_by?(users(:two)) # users(:two) is a plain member
  end

  test "can have a photo attached" do
    post = circle_posts(:family_post)
    post.photo.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    assert post.photo.attached?
  end
end
