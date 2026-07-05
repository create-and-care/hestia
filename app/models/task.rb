class Task < ApplicationRecord
  include HouseholdScoped

  belongs_to :task_category, optional: true
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :trip, optional: true
  has_many :task_reminders, dependent: :destroy

  validates :title, presence: true

  scope :general, -> { where(trip_id: nil) }

  # Non faites d'abord, puis ordre manuel (glisser-déposer), puis échéance.
  scope :ordered, -> { order(:done, :position, :id) }

  # Temps réel : la carte est ciblée par son dom_id (replace/remove) et insérée dans la
  # colonne de sa catégorie (append) — cf. vue kanban.
  after_create_commit  -> { broadcast_append_later_to household, target: board_column_id, partial: "tasks/task", locals: { task: self } }
  after_update_commit  -> { broadcast_replace_later_to household }
  after_destroy_commit -> { broadcast_remove_to household }

  def board_column_id
    task_category_id ? "tasks_category_#{task_category_id}" : "tasks_uncategorized"
  end

  # Code couleur évolutif à l'approche de l'échéance (CDC §9.3), calculé côté serveur.
  def due_status
    return :none if due_on.blank?

    days_left = (due_on - Date.current).to_i
    if days_left.negative?
      :overdue
    elsif days_left <= 1
      :urgent
    elsif days_left <= 7
      :soon
    else
      :later
    end
  end
end
