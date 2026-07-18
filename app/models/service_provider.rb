require "cgi"

class ServiceProvider < ApplicationRecord
  include HouseholdScoped

  belongs_to :service_provider_type, optional: true
  # `address` (free text) predates this and stays for providers not linked to the household's
  # address book — `linked_address` takes precedence once set (Spec: unify with Addresses).
  belongs_to :linked_address, class_name: "Address", optional: true

  validates :name, presence: true
  validate :linked_address_belongs_to_household

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(provider) { provider.household }

  def maps_url
    return linked_address.maps_url if linked_address

    "https://www.openstreetmap.org/search?query=#{CGI.escape(address)}" if address.present?
  end

  private
    def linked_address_belongs_to_household
      errors.add(:linked_address, :invalid) if linked_address && linked_address.household_id != household_id
    end
end
