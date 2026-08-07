require "test_helper"

class WorkoutTemplateTest < ActiveSupport::TestCase
  test "requires a name" do
    template = WorkoutTemplate.new(user: users(:one))
    assert_not template.valid?
    assert_includes template.errors[:name], error_message(:blank)
  end

  test "log_session creates one workout entry per exercise on the given date" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    template.workout_template_exercises.create!(exercise: "Squat", duration_minutes: 10)
    template.workout_template_exercises.create!(exercise: "Fentes")

    assert_difference -> { users(:one).workout_entries.count }, 2 do
      template.log_session(done_on: Date.current)
    end

    entries = users(:one).workout_entries.where(workout_template: template)
    assert_equal %w[Squat Fentes], entries.order(:created_at).pluck(:exercise)
    assert entries.all? { |entry| entry.done_on == Date.current }
  end

  test "destroying a template nullifies its logged entries instead of deleting them" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    template.workout_template_exercises.create!(exercise: "Squat")
    template.log_session(done_on: Date.current)
    entry = users(:one).workout_entries.last

    template.destroy

    assert WorkoutEntry.exists?(entry.id)
    assert_nil entry.reload.workout_template_id
  end
end
