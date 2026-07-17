class GiftReservation < ApplicationRecord
  belongs_to :gift_idea

  validates :token, presence: true, uniqueness: true

  before_validation :ensure_token, on: :create

  def display_name = reserver_name.presence || "Anonyme"

  private
    def ensure_token
      self.token ||= SecureRandom.urlsafe_base64(16)
    end
end
