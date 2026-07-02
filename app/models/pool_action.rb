class PoolAction < ApplicationRecord
  belongs_to :pool

  validates :done_on, presence: true
  validates :action_type, presence: true

  scope :recent, -> { order(done_on: :desc, created_at: :desc) }

  broadcasts_refreshes_to ->(action) { [ action.pool.household, "exterior" ] }
end
