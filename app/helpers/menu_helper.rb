module MenuHelper
  DAY_KEYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  def meal_type_label(type) = t("menu.meal_types.#{type}", default: type)
  def meal_type_options = MealPlanEntry::MEAL_TYPES.map { |type| [ meal_type_label(type), type ] }
  def day_name(date) = t("menu.days.#{DAY_KEYS.fetch((date.wday + 6) % 7)}")

  # Memoized: rendered once per day's add-meal dialog and once per entry's
  # edit dialog, so an unmemoized query here would run a dozen-plus times.
  def recipe_options
    @recipe_options ||= Current.household.recipes.order(:title).map { |recipe| [ recipe.title, recipe.id ] }
  end

  # Which of the household's required meal types have no entry
  # yet for this day, so the weekly Menu view can flag a gap.
  def missing_meal_types(day)
    Current.household.required_meal_types - Array(@entries[day]).map(&:meal_type)
  end
end
