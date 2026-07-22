require "test_helper"

class CirclePostReactionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post react_circle_post_path(circle_posts(:family_post), emoji: "❤️")
    assert_redirected_to new_session_path
  end

  test "create adds a reaction from the current user" do
    post_record = circle_posts(:family_post)
    assert_difference -> { post_record.circle_post_reactions.count }, 1 do
      post react_circle_post_path(post_record, emoji: "❤️")
    end
    assert_redirected_to post_record.circle
    reaction = post_record.circle_post_reactions.find_by(user: users(:one))
    assert_equal "❤️", reaction.emoji
  end

  test "create updates the existing reaction instead of duplicating" do
    post_record = circle_posts(:family_post)
    post_record.circle_post_reactions.create!(user: users(:one), emoji: "👍")

    assert_no_difference -> { post_record.circle_post_reactions.count } do
      post react_circle_post_path(post_record, emoji: "❤️")
    end
    assert_equal "❤️", post_record.circle_post_reactions.find_by(user: users(:one)).emoji
  end

  test "destroy removes the current user's reaction" do
    post_record = circle_posts(:family_post)
    post_record.circle_post_reactions.create!(user: users(:one), emoji: "👍")

    assert_difference -> { post_record.circle_post_reactions.count }, -1 do
      delete unreact_circle_post_path(post_record)
    end
  end

  # Access is by circle membership, never by household.
  test "cannot react to a post in a circle the user is not a member of" do
    other_post = circles(:other).circle_posts.create!(author: users(:two), body: "Post Beta")
    assert_no_difference -> { CirclePostReaction.count } do
      post react_circle_post_path(other_post, emoji: "❤️")
    end
    assert_response :not_found
  end

  test "create responds with a turbo stream replacing the post in place" do
    post_record = circle_posts(:family_post)
    post react_circle_post_path(post_record, emoji: "❤️"), as: :turbo_stream
    assert_turbo_stream action: "replace", target: dom_id(post_record)
  end

  test "destroy responds with a turbo stream replacing the post in place" do
    post_record = circle_posts(:family_post)
    post_record.circle_post_reactions.create!(user: users(:one), emoji: "👍")

    delete unreact_circle_post_path(post_record), as: :turbo_stream
    assert_turbo_stream action: "replace", target: dom_id(post_record)
  end

  test "a disallowed emoji is not persisted" do
    post_record = circle_posts(:family_post)
    assert_no_difference -> { post_record.circle_post_reactions.count } do
      post react_circle_post_path(post_record, emoji: "🐍")
    end
  end
end
