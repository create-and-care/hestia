class WellbeingController < ApplicationController
  PER_PAGE = 15
  PERIODS = %w[7 30 90 365 all].freeze

  # All requests go through Current.user — never Current.household.
  def show
    @period = PERIODS.include?(params[:period]) ? params[:period] : "all"
    since = period_since(@period)

    @profile = Current.user.wellbeing_profile || Current.user.build_wellbeing_profile
    @latest_weight = Current.user.weight_entries.order(recorded_on: :desc).first&.weight
    @goal_direction = goal_direction

    weight_scope = Current.user.weight_entries
    weight_scope = weight_scope.where(recorded_on: since..) if since
    @weight_entries = weight_scope.order(recorded_on: :desc).limit(PER_PAGE)
    @weight_deltas = weight_deltas_for(@weight_entries)
    @weight_chart_data = weight_scope.chronological.pluck(:recorded_on, :weight)
                            .map { |recorded_on, weight| [ recorded_on.strftime("%d/%m"), weight.to_f ] }

    workout_scope = Current.user.workout_entries
    workout_scope = workout_scope.where(done_on: since..) if since
    @workout_entries = workout_scope.recent.limit(PER_PAGE)
    @workout_templates = Current.user.workout_templates.order(:name)

    @weight_entry = Current.user.weight_entries.new(recorded_on: Date.current)
    @workout_entry = Current.user.workout_entries.new(done_on: Date.current)
  end

  # Full, paginated weight/workout history, replacing the show page's silent
  # 15-entry cap so older entries stay reachable.
  def history
    @tab = params[:tab] == "workouts" ? "workouts" : "weight"

    @weight_total = Current.user.weight_entries.count
    @weight_total_pages = [ (@weight_total / PER_PAGE.to_f).ceil, 1 ].max
    @weight_page = [ [ params[:weight_page].to_i, 1 ].max, @weight_total_pages ].min
    @weight_entries = Current.user.weight_entries.order(recorded_on: :desc).offset((@weight_page - 1) * PER_PAGE).limit(PER_PAGE)

    @workout_total = Current.user.workout_entries.count
    @workout_total_pages = [ (@workout_total / PER_PAGE.to_f).ceil, 1 ].max
    @workout_page = [ [ params[:workout_page].to_i, 1 ].max, @workout_total_pages ].min
    @workout_entries = Current.user.workout_entries.recent.offset((@workout_page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  private
    def period_since(period)
      return nil if period == "all"

      period.to_i.days.ago.to_date
    end

    # Deltas keyed by entry id, computed against the next-older entry in the
    # (already desc-ordered) relation — not against the full history, so the
    # figure matches what's visible in the current period filter.
    def weight_deltas_for(entries)
      entries.each_cons(2).each_with_object({}) do |(newer, older), deltas|
        deltas[newer.id] = (newer.weight - older.weight).round(1)
      end
    end

    # -1 (trying to lose), 0 (maintain/unknown), 1 (trying to gain) — lets the
    # view color a weight delta as good/bad relative to the user's own goal
    # instead of assuming losing weight is always the desired direction.
    def goal_direction
      return 0 unless @profile&.start_weight && @profile&.goal_weight

      @profile.goal_weight <=> @profile.start_weight
    end
end
