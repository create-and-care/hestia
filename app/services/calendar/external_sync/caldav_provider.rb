require "net/http"
require "rexml/document"

# Net::HTTP ships request classes for the common verbs only — REPORT is a
# WebDAV/CalDAV-specific method (RFC 3253) it doesn't define out of the box.
class Net::HTTP::Report < Net::HTTPRequest
  METHOD = "REPORT"
  REQUEST_HAS_BODY = true
  RESPONSE_HAS_BODY = true
end

module Calendar
  module ExternalSync
    # Generic CalDAV client (Apple/Nextcloud/Fastmail... — Spec §9.2, §16):
    # HTTP Basic Auth (no OAuth application needed, unlike Google/Microsoft),
    # a REPORT calendar-query request for VEVENTs in a time range (RFC 4791),
    # parsed via the `icalendar` gem.
    class CaldavProvider
      Error = Class.new(StandardError)

      def initialize(url, username, password)
        @uri = URI.parse(url)
        @username = username
        @password = password
      end

      # Normalized event hashes (Spec §9.2, §16): uid/title/starts_at/ends_at/all_day/location.
      def fetch_events(from:, to:)
        response = report(from, to)
        raise Error, "CalDAV request failed (#{response.code})" unless response.code.to_i.between?(200, 299)

        calendar_data_blocks(response.body).flat_map { |ics| normalize_events(ics) }
      end

      private
        def report(from, to)
          http = Net::HTTP.new(@uri.host, @uri.port)
          http.use_ssl = @uri.scheme == "https"

          request = Net::HTTP::Report.new(@uri.request_uri)
          request.basic_auth(@username, @password)
          request["Content-Type"] = "application/xml; charset=utf-8"
          request["Depth"] = "1"
          request.body = calendar_query_body(from, to)

          http.request(request)
        end

        def calendar_query_body(from, to)
          <<~XML
            <?xml version="1.0" encoding="utf-8" ?>
            <C:calendar-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
              <D:prop>
                <D:getetag/>
                <C:calendar-data/>
              </D:prop>
              <C:filter>
                <C:comp-filter name="VCALENDAR">
                  <C:comp-filter name="VEVENT">
                    <C:time-range start="#{from.utc.strftime('%Y%m%dT%H%M%SZ')}" end="#{to.utc.strftime('%Y%m%dT%H%M%SZ')}"/>
                  </C:comp-filter>
                </C:comp-filter>
              </C:filter>
            </C:calendar-query>
          XML
        end

        # Extracts each <C:calendar-data> text node (raw iCalendar/VEVENT source)
        # from the multistatus XML response, ignoring the DAV namespace prefix
        # actually used (servers vary: C:, cal:, or none).
        def calendar_data_blocks(xml_body)
          doc = REXML::Document.new(xml_body)
          REXML::XPath.match(doc, "//*[local-name()='calendar-data']").map(&:text).compact
        end

        def normalize_events(ics_text)
          Icalendar::Calendar.parse(ics_text).flat_map(&:events).map do |event|
            {
              uid: event.uid.to_s,
              title: event.summary.presence || "(untitled)",
              starts_at: event.dtstart&.to_time,
              ends_at: event.dtend&.to_time,
              all_day: event.dtstart.is_a?(Icalendar::Values::Date),
              location: event.location
            }
          end
        rescue Icalendar::Parser::ParseError
          []
        end
    end
  end
end
