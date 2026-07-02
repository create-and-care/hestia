module Calendar
  # Crée un événement de calendrier et rattache ses participants (membres du foyer).
  # Service applicatif invocable par le web, l'API et Hest.IA.
  class CreateEvent
    def self.call(household:, attributes:, participant_ids: [])
      event = household.calendar_events.create!(attributes)
      event.participants = household.users.where(id: participant_ids)
      event
    end
  end
end
