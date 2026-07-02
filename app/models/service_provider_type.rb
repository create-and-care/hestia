class ServiceProviderType < ApplicationRecord
  include HouseholdScoped

  has_many :service_providers, dependent: :nullify

  validates :name, presence: true
end
