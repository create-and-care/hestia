module CalendarHelper
  # A user-chosen hue, so the raw palette is right here — a --module-* token
  # would tie the event to a household domain it has nothing to do with. What
  # was missing is the dark half: a *-100 tint with *-800 text is a light chip,
  # and with no dark: variant every event on a dark calendar rendered as a
  # near-white block. Mirrors the pairs NotesHelper::CARD_CLASSES already uses
  # for exactly the same "user picked a color" problem.
  COLOR_CLASSES = {
    "blue" => "bg-blue-100 text-blue-800 dark:bg-blue-950/50 dark:text-blue-200",
    "green" => "bg-green-100 text-green-800 dark:bg-green-950/50 dark:text-green-200",
    "red" => "bg-red-100 text-red-800 dark:bg-red-950/50 dark:text-red-200",
    "purple" => "bg-purple-100 text-purple-800 dark:bg-purple-950/50 dark:text-purple-200",
    "orange" => "bg-orange-100 text-orange-800 dark:bg-orange-950/50 dark:text-orange-200",
    "gray" => "bg-gray-100 text-gray-800 dark:bg-gray-800/60 dark:text-gray-200"
  }.freeze

  def event_color_class(color) = COLOR_CLASSES.fetch(color, COLOR_CLASSES.fetch("blue"))
  def frequency_label(frequency) = t("calendar.frequencies.#{frequency}", default: frequency)
  def frequency_options = CalendarEvent::FREQUENCIES.map { |frequency| [ frequency_label(frequency), frequency ] }
  def color_options = CalendarEvent::COLORS.map { |color| [ color.capitalize, color ] }
  def month_label(date) = "#{t("calendar.months")[date.month - 1]} #{date.year}"
  def weekday_labels = t("calendar.weekdays")
  def event_type_label(type) = type.present? ? t("calendar_events.event_types.#{type}", default: type.humanize) : nil

  def calendar_participant_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end

  def calendar_heading(view, month, date)
    case view
    when "list" then t("calendar.show.agenda_heading")
    when "week" then t("calendar.show.week_heading", start: l(date.beginning_of_week, format: :short), end: l(date.end_of_week, format: :short))
    when "day" then l(date, format: :long)
    else month_label(month)
    end
  end

  # A birthday is represented as [time, Contact] rather than [time,
  # CalendarEvent] — the grid/list partials render either kind.
  def birthday_occurrence?(occurrence) = occurrence.is_a?(Contact)

  # Same idea for a waste collection: [time, WasteCollectionEvent] rather than [time, CalendarEvent].
  def waste_occurrence?(occurrence) = occurrence.is_a?(WasteCollectionEvent)

  # Same idea for a trip day: [time, Trip] rather than [time, CalendarEvent].
  def trip_occurrence?(occurrence) = occurrence.is_a?(Trip)
end
