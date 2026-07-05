# Rappel personnalisé sur un événement de calendrier (CDC §9.2) : délai avant
# l'occurrence + destinataire. `last_notified_occurrence_at` mémorise la dernière
# occurrence notifiée pour ne pas re-notifier deux fois la même sur une série récurrente.
class EventReminder < ApplicationRecord
  MINUTES_BEFORE_OPTIONS = [
    [ "10 minutes avant", 10 ],
    [ "30 minutes avant", 30 ],
    [ "1 heure avant", 60 ],
    [ "1 jour avant", 1440 ],
    [ "2 jours avant", 2880 ]
  ].freeze

  belongs_to :calendar_event
  belongs_to :user

  validates :minutes_before, numericality: { greater_than: 0 }

  delegate :household, to: :calendar_event
end
