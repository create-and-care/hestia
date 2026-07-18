class ServiceProviderType < ApplicationRecord
  include HouseholdScoped

  COLORS = %w[gray red orange yellow green blue purple pink].freeze

  has_many :service_providers, dependent: :nullify

  validates :name, presence: true
  validates :color, inclusion: { in: COLORS }, allow_blank: true
end
