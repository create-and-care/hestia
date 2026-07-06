require "test_helper"

module Api
  module V1
    class ConversationsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index returns only conversations the token's user participates in" do
        other_conversation = households(:alpha).conversations.create!(name: "Comite secret")

        get api_v1_conversations_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |conversation| conversation["name"] }
        assert_includes names, conversations(:alpha_chat).name
        assert_not_includes names, other_conversation.name
        assert_not_includes names, conversations(:beta_chat).name
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
