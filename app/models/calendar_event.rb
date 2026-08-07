class CalendarEvent < ApplicationRecord
  include HouseholdScoped

  FREQUENCIES = %w[none weekly monthly].freeze
  COLORS = %w[blue green red purple orange gray].freeze

  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user
  has_many :event_reminders, dependent: :destroy
  has_one :conversation, as: :subject, dependent: :nullify
  belongs_to :external_calendar_connection, optional: true
  belongs_to :address, optional: true

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }
  validates :color, inclusion: { in: COLORS }, allow_blank: true
  validate :address_belongs_to_household

  scope :chronological, -> { order(:starts_at) }

  # Events that *may* have an occurrence in [from, to] — the rows worth
  # expanding, decided in SQL. Callers used to load every event a household
  # had ever created and expand all of them in memory to find the next five.
  #
  # A series qualifies when it starts at or before the end of the window and
  # is not already finished by its beginning; a one-off qualifies only if it
  # falls inside. Expansion still decides the exact occurrences — this only
  # keeps rows that cannot possibly match out of memory.
  scope :overlapping, ->(from, to) {
    where(starts_at: ..to).where(
      "(calendar_events.frequency = 'none' AND calendar_events.starts_at >= :from) OR " \
      "(calendar_events.frequency <> 'none' AND " \
      " (calendar_events.recurrence_until IS NULL OR calendar_events.recurrence_until >= :from_date))",
      from: from, from_date: from.to_date
    )
  }

  # Real-time: the views (month/list) are computed server-side; we broadcast a
  # page refresh (Turbo morphing) on a stream dedicated to the household's calendar.
  broadcasts_refreshes_to ->(event) { [ event.household, "calendar" ] }

  def recurring? = frequency.in?(%w[weekly monthly])

  # Occurrences (start times) within [from, to]. Expands weekly/monthly recurring
  # series up to the optional recurrence end, skipping any date detached into
  # its own standalone event (excluded_occurrences — see #detach_occurrence).
  def occurrences_between(from, to)
    return [] if starts_at.blank?
    return (from..to).cover?(starts_at) ? [ starts_at ] : [] unless recurring?

    ceiling = recurrence_until ? [ to, recurrence_until.to_time.end_of_day ].min : to

    Recurrence.occurrences_between(start: starts_at, from: from, to: ceiling,
      frequency: frequency, interval: recurrence_interval.to_i.clamp(1, 52))
      .reject { |moment| excluded_occurrences.include?(moment.to_date) }
  end

  private
    def address_belongs_to_household
      errors.add(:address, :invalid) if address && address.household_id != household_id
    end
end
