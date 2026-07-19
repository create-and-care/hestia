class WellbeingController < ApplicationController
  PER_PAGE = 15

  # All requests go through Current.user — never Current.household (Spec §5.4).
  def show
    @profile = Current.user.wellbeing_profile || Current.user.build_wellbeing_profile
    @weight_entries = Current.user.weight_entries.order(recorded_on: :desc).limit(PER_PAGE)
    @workout_entries = Current.user.workout_entries.recent.limit(PER_PAGE)
    @weight_chart_data = Current.user.weight_entries.chronological.pluck(:recorded_on, :weight)
                            .map { |recorded_on, weight| [ recorded_on.strftime("%d/%m"), weight.to_f ] }
    @weight_entry = Current.user.weight_entries.new(recorded_on: Date.current)
    @workout_entry = Current.user.workout_entries.new(done_on: Date.current)
    @latest_weight = @weight_entries.first&.weight
  end

  # Full, paginated weight/workout history, replacing the show page's silent
  # 15-entry cap so older entries stay reachable (Spec §5.4: "historique complet").
  def history
    @weight_total = Current.user.weight_entries.count
    @weight_total_pages = [ (@weight_total / PER_PAGE.to_f).ceil, 1 ].max
    @weight_page = [ [ params[:weight_page].to_i, 1 ].max, @weight_total_pages ].min
    @weight_entries = Current.user.weight_entries.order(recorded_on: :desc).offset((@weight_page - 1) * PER_PAGE).limit(PER_PAGE)

    @workout_total = Current.user.workout_entries.count
    @workout_total_pages = [ (@workout_total / PER_PAGE.to_f).ceil, 1 ].max
    @workout_page = [ [ params[:workout_page].to_i, 1 ].max, @workout_total_pages ].min
    @workout_entries = Current.user.workout_entries.recent.offset((@workout_page - 1) * PER_PAGE).limit(PER_PAGE)
  end
end
