class Note < ApplicationRecord
  include HouseholdScoped

  belongs_to :author, class_name: "User", optional: true
  belongs_to :trip, optional: true

  validates :title, presence: true

  scope :general, -> { where(trip_id: nil) }
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :ordered, -> { order(favorite: :desc, updated_at: :desc) }

  broadcasts_to ->(note) { note.household }
end
