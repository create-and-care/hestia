class GiftListShare < ApplicationRecord
  belongs_to :gift_list

  validates :token, presence: true, uniqueness: true

  before_validation :ensure_token, on: :create

  private
    def ensure_token
      self.token ||= SecureRandom.urlsafe_base64(16)
    end
end
