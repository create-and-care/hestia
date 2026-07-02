module RoutinesHelper
  FREQUENCY_LABELS = {
    "daily" => "Quotidien", "weekly" => "Hebdomadaire", "monthly" => "Mensuel", "yearly" => "Annuel"
  }.freeze

  def routine_frequency_label(frequency) = FREQUENCY_LABELS.fetch(frequency, frequency)
  def routine_frequency_options = Routine::FREQUENCIES.map { |frequency| [ routine_frequency_label(frequency), frequency ] }

  def routine_member_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end
end
