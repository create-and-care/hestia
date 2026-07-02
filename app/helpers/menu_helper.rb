module MenuHelper
  MEAL_TYPE_LABELS = {
    "breakfast" => "Petit-déjeuner", "lunch" => "Déjeuner", "dinner" => "Dîner",
    "snack" => "Collation", "free" => "Libre"
  }.freeze

  DAY_NAMES = %w[Lundi Mardi Mercredi Jeudi Vendredi Samedi Dimanche].freeze

  def meal_type_label(type) = MEAL_TYPE_LABELS.fetch(type, type)
  def meal_type_options = MealPlanEntry::MEAL_TYPES.map { |type| [ meal_type_label(type), type ] }
  def day_name(date) = DAY_NAMES.fetch((date.wday + 6) % 7)

  def recipe_options
    Current.household.recipes.order(:title).map { |recipe| [ recipe.title, recipe.id ] }
  end
end
