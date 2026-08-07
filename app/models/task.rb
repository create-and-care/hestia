class Task < ApplicationRecord
  include HouseholdScoped

  belongs_to :task_category, optional: true
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :trip, optional: true
  # delete_all, not destroy: TaskReminder carries no callbacks and owns
  # nothing further, so loading every reminder of every task to delete a
  # household was work for its own sake — the largest remaining Bullet
  # finding, and one no `includes` could have addressed.
  has_many :task_reminders, dependent: :delete_all
  has_one :conversation, as: :subject, dependent: :nullify

  validates :title, presence: true

  # Thresholds for #due_status, shared with the scopes below so the dashboard's
  # SQL and the badge's Ruby always agree on what "overdue" means.
  URGENT_DAYS = 1
  SOON_DAYS = 7

  scope :general, -> { where(trip_id: nil) }

  # Not-done first, then manual order (drag-and-drop), then due date.
  scope :ordered, -> { order(:done, :position, :id) }

  # Unfinished and past due, soonest first. Replaces loading every task of the
  # household on the dashboard to keep five of them.
  scope :overdue, -> { where(done: false).where(due_on: ...Date.current).order(:due_on) }

  # Real-time: the card is targeted by its dom_id (replace/remove) and inserted into
  # its category's column (append) — cf. kanban view. The column's "empty" placeholder
  # has no dom_id of its own to be replaced, so it must be explicitly removed too, or it
  # lingers next to the newly appended card.
  after_create_commit  -> {
    broadcast_remove_to household, target: "#{board_column_id}_empty"
    broadcast_append_later_to household, target: board_column_id, partial: "tasks/task", locals: { task: self }
  }
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
    elsif days_left <= URGENT_DAYS
      :urgent
    elsif days_left <= SOON_DAYS
      :soon
    else
      :later
    end
  end
end
