class WorkoutTemplate < ApplicationRecord
  belongs_to :user
  has_many :workout_template_exercises, -> { order(:position) }, dependent: :destroy
  has_many :workout_entries, dependent: :nullify

  validates :name, presence: true

  # Logs one WorkoutEntry per exercise in the template for the given date,
  # tagged with this template so the history view can group them as one séance.
  def log_session(done_on:)
    workout_template_exercises.map do |exercise|
      workout_entries.create!(
        user: user,
        done_on: done_on,
        exercise: exercise.exercise,
        duration_minutes: exercise.duration_minutes
      )
    end
  end
end
