class WorkoutEntry < ApplicationRecord
  belongs_to :user
  belongs_to :workout_template, optional: true

  validates :done_on, presence: true
  validates :exercise, presence: true

  scope :recent, -> { order(done_on: :desc) }
end
