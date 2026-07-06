require "test_helper"

module Api
  module V1
    class MessagesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "create adds a message to a conversation the user participates in" do
        conversation = conversations(:alpha_chat)
        assert_difference -> { conversation.messages.count }, 1 do
          post api_v1_conversation_messages_path(conversation), params: { content: "Salut !" }, headers: auth_headers
        end
        assert_response :created
      end

      test "create cannot reach a conversation the user does not participate in" do
        other_conversation = households(:alpha).conversations.create!(name: "Comite secret")

        post api_v1_conversation_messages_path(other_conversation), params: { content: "Intrus" }, headers: auth_headers
        assert_response :not_found
      end

      test "create cannot reach another household's conversation" do
        post api_v1_conversation_messages_path(conversations(:beta_chat)), params: { content: "Intrus" }, headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
