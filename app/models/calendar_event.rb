class CalendarEvent < ApplicationRecord
  include HouseholdScoped

  FREQUENCIES = %w[none weekly monthly].freeze
  COLORS = %w[blue green red purple orange gray].freeze

  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }
  validates :color, inclusion: { in: COLORS }, allow_blank: true

  scope :chronological, -> { order(:starts_at) }

  # Temps réel : les vues (mois/liste) sont calculées côté serveur ; on diffuse un
  # rafraîchissement de page (morphing Turbo) sur un flux dédié au calendrier du foyer.
  broadcasts_refreshes_to ->(event) { [ event.household, "calendar" ] }

  def recurring? = frequency.in?(%w[weekly monthly])

  # Occurrences (heures de début) comprises dans [from, to]. Développe les séries
  # récurrentes hebdomadaires/mensuelles jusqu'à la fin de récurrence éventuelle.
  def occurrences_between(from, to)
    return [] if starts_at.blank?
    return (from..to).cover?(starts_at) ? [ starts_at ] : [] unless recurring?

    ceiling = recurrence_until ? [ to, recurrence_until.to_time.end_of_day ].min : to
    occurrences = []
    cursor = starts_at
    guard = 0

    while cursor <= ceiling && guard < 1_000
      occurrences << cursor if cursor >= from
      cursor = advance_from(cursor)
      guard += 1
    end

    occurrences
  end

  private
    def advance_from(time)
      Recurrence.advance(time, frequency, recurrence_interval.to_i.clamp(1, 52))
    end
end
