module CalendarHelper
  COLOR_CLASSES = {
    "blue" => "bg-blue-100 text-blue-800",
    "green" => "bg-green-100 text-green-800",
    "red" => "bg-red-100 text-red-800",
    "purple" => "bg-purple-100 text-purple-800",
    "orange" => "bg-orange-100 text-orange-800",
    "gray" => "bg-gray-100 text-gray-800"
  }.freeze

  def event_color_class(color) = COLOR_CLASSES.fetch(color, COLOR_CLASSES.fetch("blue"))
  def frequency_label(frequency) = t("calendar.frequencies.#{frequency}", default: frequency)
  def frequency_options = CalendarEvent::FREQUENCIES.map { |frequency| [ frequency_label(frequency), frequency ] }
  def color_options = CalendarEvent::COLORS.map { |color| [ color.capitalize, color ] }
  def month_label(date) = "#{t("calendar.months")[date.month - 1]} #{date.year}"
  def weekday_labels = t("calendar.weekdays")

  def calendar_participant_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end
end
