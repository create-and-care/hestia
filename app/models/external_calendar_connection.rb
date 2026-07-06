# Connection to an external calendar (Spec §9.2, §16): Google (OAuth), Microsoft
# (MSAL/OAuth), or Apple (CalDAV). Data scaffold only at this stage — the
# actual OAuth/CalDAV flow (Calendar::ExternalSync::*) requires application
# credentials (client_id/client_secret) provided by the host via
# `bin/rails credentials:edit`, not included in this repository.
#
# In production, `access_token`/`refresh_token` should be encrypted at rest via
# Active Record Encryption (`encrypts`), once the encryption keys have been generated
# for the instance (cf. README).
class ExternalCalendarConnection < ApplicationRecord
  PROVIDERS = %w[google microsoft caldav].freeze

  belongs_to :user

  validates :provider, inclusion: { in: PROVIDERS }

  scope :active, -> { where(active: true) }

  def google? = provider == "google"
  def microsoft? = provider == "microsoft"
  def caldav? = provider == "caldav"
end
