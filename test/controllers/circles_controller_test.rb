require "test_helper"

class CirclesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get circles_path
    assert_redirected_to new_session_path
  end

  test "index shows the circles the user belongs to" do
    get circles_path
    assert_response :success
    assert_includes @response.body, "Famille élargie"
    assert_not_includes @response.body, "Autre cercle"
  end

  test "show renders the feed for a member" do
    get circle_path(circles(:family))
    assert_response :success
    assert_includes @response.body, "Bonjour la famille"
  end

  test "cannot access a circle the user is not a member of" do
    get circle_path(circles(:other))
    assert_response :not_found
  end

  test "create a circle makes the creator an admin" do
    assert_difference -> { Circle.count }, 1 do
      post circles_path, params: { circle: { name: "Voisins" } }
    end
    circle = Circle.find_by!(name: "Voisins")
    assert circle.admin?(users(:one))
  end

  test "join a circle by invite code" do
    assert_difference -> { circles(:other).members.count }, 1 do
      post circle_membership_path, params: { invite_code: circles(:other).invite_code }
    end
    assert_redirected_to circles(:other)
  end

  test "member can post and author can delete" do
    circle = circles(:family)
    assert_difference -> { circle.circle_posts.count }, 1 do
      post circle_posts_path(circle), params: { circle_post: { body: "Coucou" } }, as: :turbo_stream
    end
    post_record = circle.circle_posts.order(:created_at).last
    delete circle_post_path(circle, post_record), as: :turbo_stream
    assert_not CirclePost.exists?(post_record.id)
  end

  test "react to a post" do
    post_record = circle_posts(:family_post)
    assert_difference -> { post_record.circle_post_reactions.count }, 1 do
      post react_circle_post_path(post_record, emoji: "❤️")
    end
  end
end
