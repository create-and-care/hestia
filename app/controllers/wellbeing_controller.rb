class WellbeingController < ApplicationController
  # All requests go through Current.user — never Current.household (Spec §5.4).
  def show
    @profile = Current.user.wellbeing_profile || Current.user.build_wellbeing_profile
    @weight_entries = Current.user.weight_entries.chronological
    @workout_entries = Current.user.workout_entries.recent
    @weight_entry = Current.user.weight_entries.new(recorded_on: Date.current)
    @workout_entry = Current.user.workout_entries.new(done_on: Date.current)
    @latest_weight = @weight_entries.last&.weight
  end
end
