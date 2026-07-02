class SharedProjectParticipant < ApplicationRecord
  belongs_to :shared_project
  has_many :shared_expenses, dependent: :nullify

  validates :name, presence: true
end
