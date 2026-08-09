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

  # Real-time: a page refresh (Turbo morphing) on a stream of its own, the way
  # Calendar already does it.
  #
  # Targeting the card used to be enough, because everyone was looking at the
  # same board: append into the category column, replace or remove by dom_id.
  # There are two views now, chosen per session, and no single payload is right
  # for both — #tasks_category_3 doesn't exist for a member reading the agenda,
  # so their screen just never moved. And a payload cannot know which one to be:
  # the same change puts a task in a different place depending on who is looking.
  # Refreshing lets each member's own request answer that, and it also settles
  # what a card-shaped broadcast never could — a completed task leaving its
  # due-date bucket for "Done", and the bucket counts that go with it.
  #
  # Its own stream rather than the household's: a refresh reloads the whole page,
  # and every other module's index is subscribed to that one too.
  broadcasts_refreshes_to ->(task) { [ task.household, "tasks" ] }

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
