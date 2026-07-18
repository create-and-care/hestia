require "cgi"

class Address < ApplicationRecord
  include HouseholdScoped

  TYPES = %w[restaurant cafe bar hotel boutique parc musee cinema theatre
             bien_etre lieu_phare tourisme prive autre].freeze

  belongs_to :trip, optional: true
  has_one_attached :photo
  has_many :calendar_events, dependent: :nullify
  has_many :service_providers, foreign_key: :linked_address_id, dependent: :nullify, inverse_of: :linked_address

  validates :name, presence: true
  validates :address_type, inclusion: { in: TYPES }
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :general, -> { where(trip_id: nil) }
  scope :ordered, -> { order(:name) }

  broadcasts_to ->(address) { address.household }

  def maps_url
    if latitude.present? && longitude.present?
      "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=17/#{latitude}/#{longitude}"
    elsif full_address.present?
      "https://www.openstreetmap.org/search?query=#{CGI.escape(full_address)}"
    end
  end
end
