require "test_helper"

module Api
  module V1
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_contacts_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |contact| contact["name"] }
        assert_includes names, contacts(:alpha_mom).name
        assert_not_includes names, contacts(:beta_friend).name
      end

      test "index includes the computed days_until_birthday" do
        get api_v1_contacts_path, headers: auth_headers
        contact = JSON.parse(@response.body).find { |c| c["id"] == contacts(:alpha_mom).id }
        assert_equal contacts(:alpha_mom).days_until_birthday, contact["days_until_birthday"]
      end

      test "show returns a household contact" do
        get api_v1_contact_path(contacts(:alpha_mom)), headers: auth_headers
        assert_response :success
        assert_equal contacts(:alpha_mom).name, JSON.parse(@response.body)["name"]
      end

      test "show does not leak another household's contact" do
        get api_v1_contact_path(contacts(:beta_friend)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
