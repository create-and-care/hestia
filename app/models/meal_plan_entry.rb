class MealPlanEntry < ApplicationRecord
  include HouseholdScoped

  MEAL_TYPES = %w[breakfast lunch dinner snack free].freeze

  belongs_to :recipe, optional: true
  belongs_to :trip, optional: true

  validates :on_date, presence: true
  validates :meal_type, inclusion: { in: MEAL_TYPES }
  validate :recipe_or_free_name, unless: :away?

  scope :general, -> { where(trip_id: nil) }
  scope :ordered, -> { order(:on_date, :position, :id) }

  broadcasts_refreshes_to ->(entry) { [ entry.household, "menu" ] }

  def display_name
    return I18n.t("meal_plan_entries.away_label") if away?
    recipe&.title.presence || free_name
  end

  private
    def recipe_or_free_name
      errors.add(:base, "Choisissez une recette ou un nom de repas") if recipe_id.blank? && free_name.blank?
    end
end
