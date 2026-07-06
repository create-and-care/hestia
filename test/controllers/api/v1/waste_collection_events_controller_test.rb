require "test_helper"

module Api
  module V1
    class WasteCollectionEventsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household and only returns upcoming events" do
        past_event = households(:alpha).waste_collection_events.create!(
          waste_type: "verre", collected_on: 2.days.ago.to_date
        )

        get api_v1_waste_collection_events_path, headers: auth_headers
        assert_response :success
        ids = JSON.parse(@response.body).map { |event| event["id"] }
        assert_includes ids, waste_collection_events(:alpha_event).id
        assert_not_includes ids, waste_collection_events(:beta_event).id
        assert_not_includes ids, past_event.id
      end

      test "create adds an event to the household" do
        assert_difference -> { households(:alpha).waste_collection_events.count }, 1 do
          post api_v1_waste_collection_events_path,
            params: { waste_type: "ordures", collected_on: 3.days.from_now.to_date },
            headers: auth_headers
        end
        assert_response :created
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
