class BudgetCategory < ApplicationRecord
  include HouseholdScoped

  KINDS = %w[income expense savings].freeze

  has_many :budget_entries, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :nullify

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }

  scope :ordered, -> { order(:kind, :name) }

  broadcasts_refreshes_to ->(category) { [ category.household, "budget" ] }
end
