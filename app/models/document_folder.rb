class DocumentFolder < ApplicationRecord
  include HouseholdScoped

  has_many :documents, dependent: :nullify

  validates :name, presence: true

  scope :ordered, -> { order(:name) }
end
