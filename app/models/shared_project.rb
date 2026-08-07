class SharedProject < ApplicationRecord
  include HouseholdScoped

  has_many :shared_project_participants, dependent: :destroy
  has_many :shared_expenses, dependent: :destroy
  belongs_to :trip, optional: true

  validates :name, presence: true
  validate :trip_belongs_to_household

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(project) { [ project.household, "budget" ] }

  # Summed in Ruby, not with SUM(): the index renders one of these per project
  # and preloads the expenses for it, and `sum(:amount)` would ignore that
  # preload and fire an aggregate query per row anyway.
  def total_spent
    shared_expenses.sum(&:amount)
  end

  private
    def trip_belongs_to_household
      errors.add(:trip, :invalid) if trip && trip.household_id != household_id
    end
end
