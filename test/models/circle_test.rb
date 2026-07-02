require "test_helper"

class CircleTest < ActiveSupport::TestCase
  test "generates an invite code on create" do
    circle = Circle.create!(name: "Voisins")
    assert_match(/\A[A-Z2-9]{8}\z/, circle.invite_code)
  end

  test "groups users from different households (breaks household scoping)" do
    circle = circles(:family)
    assert_includes circle.members, users(:one) # foyer alpha
    assert_includes circle.members, users(:two) # foyer beta
    assert_not_equal users(:one).households.to_a, users(:two).households.to_a
  end

  test "admin? reflects the membership role" do
    assert circles(:family).admin?(users(:one))
    assert_not circles(:family).admin?(users(:two))
  end

  test "a post is deletable by its author or a circle admin" do
    post = circle_posts(:family_post)
    assert post.deletable_by?(users(:one)) # auteur + admin
    assert_not post.deletable_by?(users(:two)) # ni auteur ni admin
  end
end
