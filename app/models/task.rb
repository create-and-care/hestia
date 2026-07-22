class Task < ApplicationRecord
  include HouseholdScoped

  belongs_to :task_category, optional: true
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :trip, optional: true
  has_many :task_reminders, dependent: :destroy
  has_one :conversation, as: :subject, dependent: :nullify

  validates :title, presence: true

  scope :general, -> { where(trip_id: nil) }

  # Not-done first, then manual order (drag-and-drop), then due date.
  scope :ordered, -> { order(:done, :position, :id) }

  # Real-time: the card is targeted by its dom_id (replace/remove) and inserted into
  # its category's column (append) — cf. kanban view.
  after_create_commit  -> { broadcast_append_later_to household, target: board_column_id, partial: "tasks/task", locals: { task: self } }
  after_update_commit  -> { broadcast_replace_later_to household }
  after_destroy_commit -> { broadcast_remove_to household }

  def board_column_id
    task_category_id ? "tasks_category_#{task_category_id}" : "tasks_uncategorized"
  end

  # Color code that evolves as the due date approaches, computed server-side.
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
