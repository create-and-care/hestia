# A recurring care schedule for a plant (watering, repotting, fertilizing...).
# Mirrors Routine's frequency/interval/next_due_on + complete! shape, scoped to a plant instead
# of a household-level generic task.
class PlantCareTask < ApplicationRecord
  # Predefined care types (Spec: "type prédéfini ou libre") — the column itself stays a plain
  # string so "other" can carry any free text the household needs, not just this list.
  CARE_TYPES = %w[watering repotting fertilizing pruning misting other].freeze

  belongs_to :plant
  has_many :plant_care_completions, dependent: :destroy

  validates :care_type, presence: true
  validates :frequency, inclusion: { in: Recurrence::PERIODS.keys }

  scope :ordered, -> { order(:next_due_on) }

  broadcasts_refreshes_to ->(task) { [ task.plant.household, "exterior" ] }

  before_validation :set_initial_due, on: :create

  def overdue? = next_due_on.present? && next_due_on < Date.current
  def due_soon?(days = 3) = next_due_on.present? && next_due_on.between?(Date.current, Date.current + days.days)

  def status
    return :overdue if overdue?
    return :soon if due_soon?

    :ok
  end

  # Completes the task: logs history (who, when) and recalculates the next due date.
  def complete!(author:, on: Date.current)
    transaction do
      plant_care_completions.create!(author: author, completed_on: on)
      update!(next_due_on: Recurrence.advance(on, frequency, interval).to_date)
    end
  end

  private
    def set_initial_due
      self.next_due_on ||= Date.current
    end
end
