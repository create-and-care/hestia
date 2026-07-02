class SharedProject < ApplicationRecord
  include HouseholdScoped

  has_many :shared_project_participants, dependent: :destroy
  has_many :shared_expenses, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(project) { [ project.household, "budget" ] }

  def total_spent
    shared_expenses.sum(:amount)
  end
end
