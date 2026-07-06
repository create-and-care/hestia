require "test_helper"

module Api
  module V1
    class NotesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household and excludes archived notes" do
        get api_v1_notes_path, headers: auth_headers
        assert_response :success
        titles = JSON.parse(@response.body).map { |note| note["title"] }
        assert_includes titles, notes(:alpha_idea).title
        assert_not_includes titles, notes(:alpha_old).title
        assert_not_includes titles, notes(:beta_note).title
      end

      test "create adds a note authored by the current user" do
        assert_difference -> { households(:alpha).notes.count }, 1 do
          post api_v1_notes_path, params: { title: "Idee sortie", content: "Parc dimanche" }, headers: auth_headers
        end
        assert_response :created
        assert_equal users(:one), households(:alpha).notes.order(:created_at).last.author
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
