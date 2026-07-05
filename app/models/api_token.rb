# Jeton d'authentification pour l'API `api/v1` (CDC §15), destiné au client mobile.
# Le jeton en clair n'est jamais stocké : seul son empreinte HMAC-SHA256 (indexée,
# recherche en O(1)) est conservée, à la manière d'un jeton d'accès personnel GitHub.
class ApiToken < ApplicationRecord
  belongs_to :user

  before_create :generate_token

  validates :name, presence: true

  attr_reader :plaintext_token

  def self.authenticate(raw_token)
    return nil if raw_token.blank?

    find_by(token_digest: digest(raw_token))
  end

  def self.digest(raw_token)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, raw_token)
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  private
    def generate_token
      raw = SecureRandom.hex(32)
      @plaintext_token = raw
      self.token_digest = self.class.digest(raw)
    end
end
