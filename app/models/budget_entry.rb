class BudgetEntry < ApplicationRecord
  PERIODICITIES = %w[monthly yearly].freeze

  belongs_to :budget_category

  validates :amount, presence: true
  validates :periodicity, inclusion: { in: PERIODICITIES }

  broadcasts_refreshes_to ->(entry) { [ entry.budget_category.household, "budget" ] }

  def monthly_amount
    periodicity == "yearly" ? amount / 12 : amount
  end
end
