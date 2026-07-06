require "test_helper"

module Calendar
  module ExternalSync
    class SyncAllJobTest < ActiveJob::TestCase
      test "syncs every active connection but skips inactive ones" do
        active = ExternalCalendarConnection.create!(user: users(:one), provider: "caldav", caldav_url: "https://caldav.example.com/a/", username: "a", access_token: "x")
        ExternalCalendarConnection.create!(user: users(:two), provider: "caldav", caldav_url: "https://caldav.example.com/b/", username: "b", access_token: "y", active: false)

        stub_request(:report, "https://caldav.example.com/a/")
          .to_return(status: 207, headers: { "Content-Type" => "application/xml" }, body: "<multistatus xmlns=\"DAV:\"></multistatus>")

        SyncAllJob.perform_now

        assert_not_nil active.reload.last_synced_at
        assert_not_requested :report, "https://caldav.example.com/b/"
      end
    end
  end
end
