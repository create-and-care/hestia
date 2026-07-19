class SharedProjectParticipant < ApplicationRecord
  belongs_to :shared_project
  has_many :shared_expenses, dependent: :nullify

  validates :name, presence: true

  broadcasts_refreshes_to ->(participant) { [ participant.shared_project, "project" ] }
end
