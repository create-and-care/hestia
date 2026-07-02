require "cgi"

class ServiceProvider < ApplicationRecord
  include HouseholdScoped

  belongs_to :service_provider_type, optional: true

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(provider) { provider.household }

  def maps_url
    "https://www.openstreetmap.org/search?query=#{CGI.escape(address)}" if address.present?
  end
end
