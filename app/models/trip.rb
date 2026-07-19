class Trip < ApplicationRecord
  include HouseholdScoped

  # Deleting the trip = deleting all attached data (Spec §12.3).
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :shopping_lists, dependent: :destroy
  has_many :addresses, dependent: :destroy
  # Trip expenses reuse Budget's own split engine (Spec §11.4/§12.3: "Trip
  # (same split engine)") rather than duplicating shared-expense tracking.
  has_one :shared_project, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(starts_on: :desc, name: :asc) }
end
