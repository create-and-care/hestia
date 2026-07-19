class DocumentFolder < ApplicationRecord
  include HouseholdScoped

  COLORS = %w[blue green red purple orange gray].freeze

  has_many :documents, dependent: :nullify

  validates :name, presence: true
  validates :color, inclusion: { in: COLORS }, allow_blank: true

  scope :ordered, -> { order(:name) }

  # Same stream as Document — the index page listens once and gets both.
  broadcasts_refreshes_to ->(folder) { [ folder.household, "documents" ] }
end
