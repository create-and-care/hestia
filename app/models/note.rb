class Note < ApplicationRecord
  include HouseholdScoped

  belongs_to :author, class_name: "User", optional: true

  validates :title, presence: true

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :ordered, -> { order(favorite: :desc, updated_at: :desc) }

  broadcasts_to ->(note) { note.household }
end
