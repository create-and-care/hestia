require "test_helper"

module Api
  module V1
    class FeedingSessionsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the given baby profile within the token's household" do
        baby = baby_profiles(:alpha_baby)
        session = baby.feeding_sessions.create!(kind: "bottle", started_at: 1.hour.ago, ended_at: 30.minutes.ago)

        get api_v1_baby_profile_feeding_sessions_path(baby), headers: auth_headers
        assert_response :success
        ids = JSON.parse(@response.body).map { |item| item["id"] }
        assert_includes ids, session.id
      end

      test "index cannot reach another household's baby profile" do
        get api_v1_baby_profile_feeding_sessions_path(baby_profiles(:beta_baby)), headers: auth_headers
        assert_response :not_found
      end

      test "create adds a feeding session to the baby profile" do
        baby = baby_profiles(:alpha_baby)
        assert_difference -> { baby.feeding_sessions.count }, 1 do
          post api_v1_baby_profile_feeding_sessions_path(baby),
            params: { kind: "breast", started_at: 1.hour.ago, ended_at: 40.minutes.ago },
            headers: auth_headers
        end
        assert_response :created
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
