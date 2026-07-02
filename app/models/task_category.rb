class TaskCategory < ApplicationRecord
  include HouseholdScoped

  has_many :tasks, dependent: :nullify

  validates :name, presence: true
end
