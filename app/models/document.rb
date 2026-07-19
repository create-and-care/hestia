class Document < ApplicationRecord
  include HouseholdScoped

  belongs_to :document_folder, optional: true
  belongs_to :documentable, polymorphic: true, optional: true
  has_one_attached :file

  validates :name, presence: true
  validates :file, presence: true
  validate :documentable_belongs_to_household

  scope :ordered, -> { order(created_at: :desc) }

  broadcasts_refreshes_to ->(document) { [ document.household, "documents" ] }

  private
    def documentable_belongs_to_household
      errors.add(:documentable, :invalid) if documentable && documentable.household_id != household_id
    end
end
