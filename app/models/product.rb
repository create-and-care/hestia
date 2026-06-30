class Product < ApplicationRecord
  include HouseholdScoped

  has_many :shopping_list_items, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :household_id, case_sensitive: false }
end
