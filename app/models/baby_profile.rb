class BabyProfile < ApplicationRecord
  include HouseholdScoped

  has_many :feeding_sessions, dependent: :destroy
  has_many :food_introductions, dependent: :destroy
  has_many :allergen_tests, dependent: :destroy
  belongs_to :service_provider, optional: true

  validates :name, presence: true
  validate :service_provider_belongs_to_household

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(baby) { baby.household }

  def age_in_months
    return if born_on.blank?

    months = (Date.current.year * 12 + Date.current.month) - (born_on.year * 12 + born_on.month)
    months -= 1 if Date.current.day < born_on.day
    months
  end

  private
    def service_provider_belongs_to_household
      errors.add(:service_provider, :invalid) if service_provider && service_provider.household_id != household_id
    end
end
