class SharedExpense < ApplicationRecord
  belongs_to :shared_project
  belongs_to :shared_project_participant, optional: true # the payer

  validates :amount, presence: true

  scope :recent, -> { order(spent_on: :desc, created_at: :desc) }

  broadcasts_refreshes_to ->(expense) { [ expense.shared_project, "project" ] }
end
