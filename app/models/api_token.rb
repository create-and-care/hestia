# Authentication token for the `api/v1` API, intended for the mobile client.
# The plaintext token is never stored: only its HMAC-SHA256 fingerprint (indexed,
# O(1) lookup) is kept, in the manner of a GitHub personal access token.
class ApiToken < ApplicationRecord
  belongs_to :user

  before_create :generate_token

  validates :name, presence: true

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  attr_reader :plaintext_token

  def self.authenticate(raw_token)
    return nil if raw_token.blank?

    active.find_by(token_digest: digest(raw_token))
  end

  def self.digest(raw_token)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, raw_token)
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  private
    def generate_token
      raw = SecureRandom.hex(32)
      @plaintext_token = raw
      self.token_digest = self.class.digest(raw)
    end
end
