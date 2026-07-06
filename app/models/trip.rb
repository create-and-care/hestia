class Trip < ApplicationRecord
  include HouseholdScoped

  # Deleting the trip = deleting all attached data (Spec §12.3).
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :shopping_lists, dependent: :destroy
  has_many :addresses, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(starts_on: :desc, name: :asc) }
end
