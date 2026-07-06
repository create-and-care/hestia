module TasksHelper
  # Due-date status → badge Tailwind classes (label comes from the tasks.due locale scope).
  DUE_BADGE_CLASSES = {
    overdue: "bg-red-100 text-red-700",
    urgent:  "bg-orange-100 text-orange-700",
    soon:    "bg-yellow-100 text-yellow-800",
    later:   "bg-gray-100 text-gray-600",
    none:    nil
  }.freeze

  def due_label(status) = status == :none ? nil : t("tasks.due.#{status}")
  def due_badge_class(status) = DUE_BADGE_CLASSES.fetch(status)

  def task_assignee_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end

  def task_category_options
    Current.household.task_categories.order(:name).map { |category| [ category.name, category.id ] }
  end
end
