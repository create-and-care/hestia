class PetSupply < ApplicationRecord
  belongs_to :pet

  validates :name, presence: true

  scope :ordered, -> { order(:next_order_on, :name) }
end
