class Document < ApplicationRecord
  include HouseholdScoped

  belongs_to :document_folder, optional: true
  has_one_attached :file

  validates :name, presence: true
  validates :file, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  broadcasts_refreshes_to ->(document) { [ document.household, "documents" ] }
end
