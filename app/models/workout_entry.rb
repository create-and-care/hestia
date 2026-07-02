class WorkoutEntry < ApplicationRecord
  belongs_to :user

  validates :done_on, presence: true
  validates :exercise, presence: true

  scope :recent, -> { order(done_on: :desc) }
end
