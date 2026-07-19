class FeedingSession < ApplicationRecord
  KINDS = %w[bottle breast].freeze

  belongs_to :baby_profile

  validates :kind, inclusion: { in: KINDS }

  scope :recent, -> { order(started_at: :desc, created_at: :desc) }
  scope :in_progress, -> { where(ended_at: nil) }

  broadcasts_refreshes_to ->(session) { [ session.baby_profile.household, "baby" ] }

  def duration_minutes
    return unless started_at && ended_at

    ((ended_at - started_at) / 60).round
  end
end
