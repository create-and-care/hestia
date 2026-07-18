class Note < ApplicationRecord
  include HouseholdScoped

  COLORS = %w[default yellow pink blue green purple].freeze

  belongs_to :author, class_name: "User", optional: true
  belongs_to :trip, optional: true
  belongs_to :recipe, optional: true
  belongs_to :document, optional: true

  validates :title, presence: true
  validates :color, inclusion: { in: COLORS }
  validate :recipe_belongs_to_household
  validate :document_belongs_to_household

  scope :general, -> { where(trip_id: nil) }
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :ordered, -> { order(favorite: :desc, updated_at: :desc) }

  broadcasts_to ->(note) { note.household }

  # `broadcasts_to`'s default update only replaces the note's own DOM node in place, which can't
  # reorder it (favorite sorts to top) or show/hide it across other viewers' active/archived
  # filters. A page refresh re-renders each viewer's own current index request (their own
  # q/archived params), so it's the only broadcast that can resolve per-viewer filter state.
  after_update_commit -> { broadcast_refresh_to household }, if: :saved_change_to_favorite_or_archived?

  private
    def saved_change_to_favorite_or_archived?
      saved_change_to_favorite? || saved_change_to_archived?
    end

    def recipe_belongs_to_household
      errors.add(:recipe, :invalid) if recipe && recipe.household_id != household_id
    end

    def document_belongs_to_household
      errors.add(:document, :invalid) if document && document.household_id != household_id
    end
end
