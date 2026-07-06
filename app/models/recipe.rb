class Recipe < ApplicationRecord
  include HouseholdScoped

  has_many :recipe_ingredients, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  has_many :recipe_steps, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  # A planned meal linked to a deleted recipe switches to a "free name" (Spec §11.1).
  has_many :meal_plan_entries, dependent: :nullify

  before_destroy :preserve_meal_plan_names, prepend: true

  validates :title, presence: true

  scope :ordered, -> { order(:title) }

  broadcasts_to ->(recipe) { recipe.household }

  # Text representations (one line per item) for forms and import.
  def ingredients_text = recipe_ingredients.map(&:name).join("\n")
  def steps_text = recipe_steps.map(&:content).join("\n")
  def tags_text = tags.join(", ")

  def total_time_minutes
    [ prep_time_minutes, cook_time_minutes ].compact.sum if prep_time_minutes || cook_time_minutes
  end

  private
    def preserve_meal_plan_names
      meal_plan_entries.where(free_name: [ nil, "" ]).update_all(free_name: title)
    end
end
