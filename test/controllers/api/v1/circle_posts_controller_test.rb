require "test_helper"

module Api
  module V1
    class CirclePostsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes by circle membership, not household" do
        get api_v1_circle_posts_path(circles(:family)), headers: auth_headers
        assert_response :success
        bodies = JSON.parse(@response.body).map { |post| post["body"] }
        assert_includes bodies, circle_posts(:family_post).body
      end

      # users(:one) is a member of :family but not of :other — proves the
      # architecture deviation (membership-based, not household-based) is real.
      test "index returns 404 for a circle the token's user does not belong to" do
        get api_v1_circle_posts_path(circles(:other)), headers: auth_headers
        assert_response :not_found
      end

      test "create adds a post to a circle the token's user belongs to" do
        assert_difference -> { circles(:family).circle_posts.count }, 1 do
          post api_v1_circle_posts_path(circles(:family)), params: { body: "Coucou !" }, headers: auth_headers
        end
        assert_response :created
      end

      test "create returns 404 for a circle the token's user does not belong to" do
        post api_v1_circle_posts_path(circles(:other)), params: { body: "Hack" }, headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
