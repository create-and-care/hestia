module TasksHelper
  # Statut d'échéance → [libellé, classes Tailwind du badge].
  DUE = {
    overdue: [ "En retard", "bg-red-100 text-red-700" ],
    urgent:  [ "Aujourd'hui / demain", "bg-orange-100 text-orange-700" ],
    soon:    [ "Cette semaine", "bg-yellow-100 text-yellow-800" ],
    later:   [ "Plus tard", "bg-gray-100 text-gray-600" ],
    none:    [ nil, nil ]
  }.freeze

  def due_label(status) = DUE.fetch(status).first
  def due_badge_class(status) = DUE.fetch(status).last

  def task_assignee_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end

  def task_category_options
    Current.household.task_categories.order(:name).map { |category| [ category.name, category.id ] }
  end
end
