class Recipe < ApplicationRecord
  include HouseholdScoped

  # Set only when cloned from the catalog (Recipes::Catalog::AddToHousehold),
  # purely so "Découvrir" can tell it's already in this household's book —
  # never displayed, unlike source_url which stays reserved for the
  # user-driven "import from a URL" flow.
  belongs_to :recipe_catalog_entry, optional: true

  has_many :recipe_ingredients, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  has_many :recipe_steps, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  # A planned meal linked to a deleted recipe switches to a "free name" (Spec §11.1).
  has_many :meal_plan_entries, dependent: :nullify
  # Notes/Wine Cellar interconnections (Spec §9.5): a note or a bottle can
  # reference the recipe it's about (a wine pairing, a tasting note…);
  # deleting the recipe just unlinks them, it never takes the note/bottle with it.
  has_many :notes, dependent: :nullify
  has_many :bottles, dependent: :nullify

  has_one_attached :photo

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
