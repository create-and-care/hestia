require "test_helper"

module Api
  module V1
    class PetsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_pets_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |pet| pet["name"] }
        assert_includes names, pets(:alpha_dog).name
        assert_not_includes names, pets(:beta_cat).name
      end

      test "show returns a household pet" do
        get api_v1_pet_path(pets(:alpha_dog)), headers: auth_headers
        assert_response :success
        assert_equal pets(:alpha_dog).name, JSON.parse(@response.body)["name"]
      end

      test "show does not leak another household's pet" do
        get api_v1_pet_path(pets(:beta_cat)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
