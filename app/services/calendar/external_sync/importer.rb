module Calendar
  module ExternalSync
    # Upserts normalized external events (Spec §9.2, §16) into CalendarEvent,
    # keyed by [connection, external_uid] so a re-sync updates in place rather
    # than duplicating. Imported events are read-only from the source's point
    # of view but remain regular, editable CalendarEvent rows locally.
    class Importer
      IMPORTED_COLOR = "gray"

      def self.call(...) = new(...).call

      def initialize(connection, events)
        @connection = connection
        @events = events
      end

      def call
        @events.each { |event| upsert(event) }
      end

      private
        def upsert(event)
          return if event[:starts_at].blank?

          record = @connection.calendar_events.find_or_initialize_by(external_uid: event[:uid])
          record.assign_attributes(
            household: @connection.user.households.first,
            title: event[:title],
            location: event[:location],
            starts_at: event[:starts_at],
            ends_at: event[:ends_at],
            all_day: event[:all_day] || false,
            # A consistent, distinct color so an imported event is visually
            # recognizable as coming from an external calendar (Spec §9.2
            # business rule) — the source's own color isn't otherwise
            # representable in Hestia's fixed 6-color set. Only set on first
            # import: a color the user changed afterward must survive re-syncs.
            color: record.new_record? ? IMPORTED_COLOR : record.color
          )
          record.save!
        end
    end
  end
end
