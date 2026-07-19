class Trip < ApplicationRecord
  include HouseholdScoped

  # A la carte sub-modules (mirrors Household#disabled_modules), so a trip
  # can hide the sections it doesn't need instead of showing all of them.
  SECTIONS = %w[shopping_lists notes tasks addresses menu].freeze

  # Deleting the trip = deleting all attached data (Spec §12.3).
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :shopping_lists, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :meal_plan_entries, dependent: :destroy

  validates :name, presence: true
  validate :disabled_sections_are_known_keys

  scope :ordered, -> { order(starts_on: :desc, name: :asc) }

  def section_enabled?(key)
    disabled_sections.exclude?(key.to_s)
  end

  private
    def disabled_sections_are_known_keys
      unknown = disabled_sections.to_a - SECTIONS
      errors.add(:disabled_sections, "contains unknown section keys: #{unknown.join(', ')}") if unknown.any?
    end
end
