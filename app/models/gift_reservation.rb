class GiftReservation < ApplicationRecord
  belongs_to :gift_idea

  def display_name = reserver_name.presence || "Anonyme"
end
