class ServiceProviderType < ApplicationRecord
  include HouseholdScoped

  COLORS = %w[gray red orange yellow green blue purple pink].freeze
  PREDEFINED_NAMES = %w[
    plumber electrician heating_technician gardener cleaner babysitter tutor
    vet doctor painter locksmith it_support insurance hairdresser mover
  ].freeze

  has_many :service_providers, dependent: :nullify

  validates :name, presence: true
  validates :color, inclusion: { in: COLORS }, allow_blank: true
end
