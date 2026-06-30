class Session < ApplicationRecord
  belongs_to :user
  belongs_to :active_household, class_name: "Household", optional: true
end
