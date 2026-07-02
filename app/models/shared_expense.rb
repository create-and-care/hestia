class SharedExpense < ApplicationRecord
  belongs_to :shared_project
  belongs_to :shared_project_participant, optional: true # le payeur

  validates :amount, presence: true

  scope :recent, -> { order(spent_on: :desc, created_at: :desc) }
end
