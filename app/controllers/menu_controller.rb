class MenuController < ApplicationController
  # Weekly meal plan (Spec §11.1).
  def show
    @week_start = parse_monday
    @days = (@week_start..(@week_start + 6.days)).to_a
    @entries = Current.household.meal_plan_entries
      .general
      .where(on_date: @week_start..(@week_start + 6.days))
      .includes(:recipe)
      .ordered
      .group_by(&:on_date)
    @entry = Current.household.meal_plan_entries.new(on_date: Date.current, meal_type: "dinner")
  end

  private
    def parse_monday
      base = begin
        Date.parse(params[:week])
      rescue ArgumentError, TypeError
        Date.current
      end
      base.beginning_of_week
    end
end
