class RecipeCatalogEntry < ApplicationRecord
  validates :title, presence: true
  validates :source_url, presence: true, uniqueness: true

  scope :ordered, -> { order(:title) }
  scope :search, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :tagged, ->(tag) { where("? = ANY(tags)", tag) }

  # Drives the tag filter select on the "Découvrir" tab — only ever shows
  # tags actually present in the catalog.
  def self.all_tags
    pluck(Arel.sql("DISTINCT unnest(tags)")).compact.sort
  end

  def ingredients_text = ingredients.join("\n")
  def steps_text = steps.join("\n")

  def total_time_minutes
    [ prep_time_minutes, cook_time_minutes ].compact.sum if prep_time_minutes || cook_time_minutes
  end
end
