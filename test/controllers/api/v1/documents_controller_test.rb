require "test_helper"

module Api
  module V1
    class DocumentsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_documents_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |document| document["name"] }
        assert_includes names, documents(:alpha_doc).name
        assert_not_includes names, documents(:beta_doc).name
      end

      test "index honors a custom per_page" do
        get api_v1_documents_path(per_page: 1), headers: auth_headers
        assert_response :success
        assert_equal 1, JSON.parse(@response.body).size
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
