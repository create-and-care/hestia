class Routine < ApplicationRecord
  include HouseholdScoped

  FREQUENCIES = %w[daily weekly monthly yearly].freeze

  belongs_to :assignee, class_name: "User", optional: true
  has_many :routine_completions, dependent: :destroy

  validates :name, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }

  scope :ordered, -> { order(:next_due_on, :name) }

  broadcasts_to ->(routine) { routine.household }

  before_validation :set_initial_due, on: :create

  def overdue?
    next_due_on.present? && next_due_on < Date.current
  end

  # Completes the routine: logs history (who, when) and recalculates the next due date.
  def complete!(author:, on: Date.current)
    transaction do
      routine_completions.create!(author: author, completed_on: on)
      update!(next_due_on: Recurrence.advance(on, frequency, interval).to_date)
    end
  end

  private
    def set_initial_due
      self.next_due_on ||= Date.current
    end
end
