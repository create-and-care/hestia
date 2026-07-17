require "test_helper"

class CirclePostsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post circle_posts_path(circles(:family)), params: { circle_post: { body: "Coucou" } }, as: :turbo_stream
    assert_redirected_to new_session_path
  end

  test "create adds a post authored by the current user" do
    circle = circles(:family)
    assert_difference -> { circle.circle_posts.count }, 1 do
      post circle_posts_path(circle), params: { circle_post: { body: "Coucou" } }, as: :turbo_stream
    end
    assert_equal users(:one), circle.circle_posts.order(:created_at).last.author
  end

  test "create redirects to the circle for an html request" do
    circle = circles(:family)
    post circle_posts_path(circle), params: { circle_post: { body: "Coucou" } }
    assert_redirected_to circle
  end

  # Access is by circle membership, never by household (Spec §5, point 1).
  test "cannot post to a circle the user is not a member of" do
    assert_no_difference -> { CirclePost.count } do
      post circle_posts_path(circles(:other)), params: { circle_post: { body: "Hack" } }, as: :turbo_stream
    end
    assert_response :not_found
  end

  test "author can delete their own post" do
    post_record = circle_posts(:family_post) # authored by users(:one)
    delete circle_post_path(circles(:family), post_record), as: :turbo_stream
    assert_not CirclePost.exists?(post_record.id)
  end

  test "a member who is neither author nor admin cannot delete a post" do
    sign_in_as(users(:two)) # family_two, role: member
    post_record = circle_posts(:family_post) # authored by users(:one), the family admin
    delete circle_post_path(circles(:family), post_record), as: :turbo_stream
    assert CirclePost.exists?(post_record.id)
  end

  test "cannot delete a post in a circle the user is not a member of" do
    other_post = circles(:other).circle_posts.create!(author: users(:two), body: "Post Beta")
    assert_no_difference -> { CirclePost.count } do
      delete circle_post_path(circles(:other), other_post), as: :turbo_stream
    end
    assert_response :not_found
  end

  test "destroy by a non-author non-admin returns forbidden instead of silently no-op'ing" do
    sign_in_as(users(:two))
    post_record = circle_posts(:family_post) # authored by users(:one), the family admin
    delete circle_post_path(circles(:family), post_record), as: :turbo_stream
    assert_response :forbidden
  end

  test "create attaches an optional photo" do
    circle = circles(:family)
    photo = fixture_file_upload("sample.png", "image/png")
    post circle_posts_path(circle), params: { circle_post: { body: "Regardez !", photo: photo } }, as: :turbo_stream
    assert circle.circle_posts.order(:created_at).last.photo.attached?
  end

  test "create with a blank body redirects with an error instead of silently resetting the form" do
    circle = circles(:family)
    assert_no_difference -> { circle.circle_posts.count } do
      post circle_posts_path(circle), params: { circle_post: { body: "" } }, as: :turbo_stream
    end
    assert_redirected_to circle
    assert_equal "Body can't be blank", flash[:alert]
  end
end
