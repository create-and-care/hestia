# Catalog of plant care sheets, built up progressively
# (cf. seed in db/seeds.rb). A Plant without an associated reference remains
# functional, simply without the care-help value.
class PlantReference < ApplicationRecord
  has_many :plants, dependent: :nullify

  validates :common_name, presence: true, uniqueness: true

  scope :ordered, -> { order(:common_name) }
end
