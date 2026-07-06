# Connection to an external calendar (Spec §9.2, §16): Google (OAuth), Microsoft
# (OAuth), or a generic CalDAV server (Apple/Nextcloud/Fastmail...). The actual
# OAuth/CalDAV sync (Calendar::ExternalSync::*) requires application credentials
# (client_id/client_secret for Google/Microsoft) provided by the host via
# `bin/rails credentials:edit` — CalDAV needs no such app-level credential, only
# the per-connection server URL/username/password entered by the user.
#
# `access_token`/`refresh_token` (OAuth tokens, or the CalDAV password reusing
# the `access_token` column) are encrypted at rest via Active Record Encryption —
# the 3 required keys are generated once per instance (`bin/rails db:encryption:init`,
# see README).
class ExternalCalendarConnection < ApplicationRecord
  PROVIDERS = %w[google microsoft caldav].freeze

  belongs_to :user
  has_many :calendar_events, dependent: :nullify

  encrypts :access_token, :refresh_token

  validates :provider, inclusion: { in: PROVIDERS }
  validates :caldav_url, presence: true, if: :caldav?
  validates :username, presence: true, if: :caldav?

  scope :active, -> { where(active: true) }

  def google? = provider == "google"
  def microsoft? = provider == "microsoft"
  def caldav? = provider == "caldav"

  def oauth_provider? = google? || microsoft?

  def token_expired? = expires_at.present? && expires_at <= Time.current
end
