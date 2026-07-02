class ContactTag < ApplicationRecord
  include HouseholdScoped

  has_many :contact_taggings, dependent: :destroy
  has_many :contacts, through: :contact_taggings

  validates :name, presence: true
end
