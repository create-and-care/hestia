require "test_helper"

module Calendar
  module ExternalSync
    class CaldavProviderTest < ActiveSupport::TestCase
      MULTISTATUS = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <multistatus xmlns="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
          <response>
            <href>/cal/event1.ics</href>
            <propstat>
              <prop>
                <C:calendar-data>BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VEVENT
        UID:event1
        SUMMARY:Team lunch
        LOCATION:Cafe
        DTSTART:20260801T120000Z
        DTEND:20260801T130000Z
        END:VEVENT
        END:VCALENDAR
        </C:calendar-data>
              </prop>
            </propstat>
          </response>
        </multistatus>
      XML

      test "fetch_events parses VEVENTs out of the multistatus response" do
        stub_request(:report, "https://caldav.example.com/cal/")
          .to_return(status: 207, headers: { "Content-Type" => "application/xml" }, body: MULTISTATUS)

        events = CaldavProvider.new("https://caldav.example.com/cal/", "alice", "secret").fetch_events(
          from: Time.zone.parse("2026-08-01"), to: Time.zone.parse("2026-08-31")
        )

        assert_equal 1, events.size
        assert_equal "event1", events.first[:uid]
        assert_equal "Team lunch", events.first[:title]
        assert_equal "Cafe", events.first[:location]
      end

      test "sends HTTP Basic Auth credentials" do
        stub = stub_request(:report, "https://caldav.example.com/cal/")
          .with(basic_auth: [ "alice", "secret" ])
          .to_return(status: 207, headers: { "Content-Type" => "application/xml" }, body: "<multistatus xmlns=\"DAV:\"></multistatus>")

        CaldavProvider.new("https://caldav.example.com/cal/", "alice", "secret").fetch_events(from: Time.current, to: 1.month.from_now)

        assert_requested stub
      end

      test "raises a CaldavProvider::Error on a non-2xx response" do
        stub_request(:report, "https://caldav.example.com/cal/").to_return(status: 401)

        assert_raises(CaldavProvider::Error) do
          CaldavProvider.new("https://caldav.example.com/cal/", "alice", "wrong").fetch_events(from: Time.current, to: 1.month.from_now)
        end
      end
    end
  end
end
