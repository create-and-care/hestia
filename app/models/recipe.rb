class Recipe < ApplicationRecord
  include HouseholdScoped

  has_many :recipe_ingredients, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  has_many :recipe_steps, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy

  validates :title, presence: true

  scope :ordered, -> { order(:title) }

  broadcasts_to ->(recipe) { recipe.household }

  # Représentations texte (une ligne par élément) pour les formulaires et l'import.
  def ingredients_text = recipe_ingredients.map(&:name).join("\n")
  def steps_text = recipe_steps.map(&:content).join("\n")
  def tags_text = tags.join(", ")

  def total_time_minutes
    [ prep_time_minutes, cook_time_minutes ].compact.sum if prep_time_minutes || cook_time_minutes
  end
end
