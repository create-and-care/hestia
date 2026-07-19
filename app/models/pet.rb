class Pet < ApplicationRecord
  include HouseholdScoped

  has_many :pet_vaccinations, dependent: :destroy
  has_many :pet_treatments, dependent: :destroy
  has_many :pet_supplies, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :nullify
  has_one_attached :photo
  belongs_to :service_provider, optional: true

  validates :name, presence: true
  validate :service_provider_belongs_to_household

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(pet) { pet.household }

  def age
    return if born_on.blank?

    years = Date.current.year - born_on.year
    years -= 1 if anniversary_this_year > Date.current
    years
  end

  private
    def anniversary_this_year
      Date.new(Date.current.year, born_on.month, born_on.day)
    rescue Date::Error
      Date.new(Date.current.year, born_on.month, -1)
    end

    def service_provider_belongs_to_household
      errors.add(:service_provider, :invalid) if service_provider && service_provider.household_id != household_id
    end
end
