class WorkoutTemplateExercise < ApplicationRecord
  belongs_to :workout_template

  validates :exercise, presence: true

  before_create :assign_position

  private
    def assign_position
      self.position = (workout_template.workout_template_exercises.maximum(:position) || -1) + 1
    end
end
