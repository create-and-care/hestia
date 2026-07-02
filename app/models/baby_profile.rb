class BabyProfile < ApplicationRecord
  include HouseholdScoped

  has_many :feeding_sessions, dependent: :destroy
  has_many :food_introductions, dependent: :destroy
  has_many :allergen_tests, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(baby) { baby.household }
end
