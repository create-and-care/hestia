module CalendarHelper
  COLOR_CLASSES = {
    "blue" => "bg-blue-100 text-blue-800",
    "green" => "bg-green-100 text-green-800",
    "red" => "bg-red-100 text-red-800",
    "purple" => "bg-purple-100 text-purple-800",
    "orange" => "bg-orange-100 text-orange-800",
    "gray" => "bg-gray-100 text-gray-800"
  }.freeze

  FREQUENCY_LABELS = { "none" => "Aucune", "weekly" => "Hebdomadaire", "monthly" => "Mensuelle" }.freeze
  MONTH_NAMES = %w[Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre].freeze
  WEEKDAYS = %w[Lun Mar Mer Jeu Ven Sam Dim].freeze

  def event_color_class(color) = COLOR_CLASSES.fetch(color, COLOR_CLASSES.fetch("blue"))
  def frequency_label(frequency) = FREQUENCY_LABELS.fetch(frequency, frequency)
  def frequency_options = CalendarEvent::FREQUENCIES.map { |frequency| [ frequency_label(frequency), frequency ] }
  def color_options = CalendarEvent::COLORS.map { |color| [ color.capitalize, color ] }
  def month_label(date) = "#{MONTH_NAMES.fetch(date.month - 1)} #{date.year}"

  def calendar_participant_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end
end
