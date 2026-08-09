module TasksHelper
  # Due-date status → Ui::BadgeComponent variant (label comes from the tasks.due locale scope).
  DUE_BADGE_VARIANTS = {
    overdue:     :destructive,
    destructive: :destructive,
    soon:        :warning,
    later:       :secondary,
    none:        nil
  }.freeze

  def due_label(status) = status == :none ? nil : t("tasks.due.#{status}")
  def due_badge_variant(status) = DUE_BADGE_VARIANTS.fetch(status)

  def task_assignee_options
    Current.household.users.order(:name).map { |user| [ user.name.presence || user.email_address, user.id ] }
  end

  def task_category_options
    Current.household.task_categories.order(:name).map { |category| [ category.name, category.id ] }
  end
end
