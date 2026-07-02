class RoutineCompletion < ApplicationRecord
  belongs_to :routine
  belongs_to :author, class_name: "User", optional: true

  validates :completed_on, presence: true

  scope :recent, -> { order(completed_on: :desc) }
end
