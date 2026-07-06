module MenuHelper
  DAY_KEYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  def meal_type_label(type) = t("menu.meal_types.#{type}", default: type)
  def meal_type_options = MealPlanEntry::MEAL_TYPES.map { |type| [ meal_type_label(type), type ] }
  def day_name(date) = t("menu.days.#{DAY_KEYS.fetch((date.wday + 6) % 7)}")

  def recipe_options
    Current.household.recipes.order(:title).map { |recipe| [ recipe.title, recipe.id ] }
  end
end
