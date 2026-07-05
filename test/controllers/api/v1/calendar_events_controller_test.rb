require "test_helper"

module Api
  module V1
    class CalendarEventsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index returns occurrences scoped to the token's household within the default window" do
        get api_v1_calendar_events_path, headers: auth_headers
        assert_response :success
        titles = JSON.parse(@response.body).map { |occurrence| occurrence["title"] }
        assert_includes titles, calendar_events(:alpha_meeting).title
        assert_not_includes titles, calendar_events(:beta_event).title
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
