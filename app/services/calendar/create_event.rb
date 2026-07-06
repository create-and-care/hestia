module Calendar
  # Creates a calendar event and attaches its participants (household members).
  # Application service invocable by the web, the API and Hest.AI.
  class CreateEvent
    def self.call(household:, attributes:, participant_ids: [])
      event = household.calendar_events.create!(attributes)
      event.participants = household.users.where(id: participant_ids)
      event
    end
  end
end
