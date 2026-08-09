# Expiration status of a record with an `expires_on` column.
# Computed server-side from the current date (never fixed at creation time),
# to stay correct without any action from the user.
module Perishable
  extend ActiveSupport::Concern

  # Named so the `expiring` scope and #expiration_status share one definition
  # of "soon": the dashboard filters in SQL, the badge classifies in Ruby, and
  # a threshold changed in one place has to move in both.
  URGENT_DAYS = 1 # overdue today / tomorrow
  SOON_DAYS = 3   # 2 to 3 days

  included do
    # Everything :expired, :destructive or :soon — i.e. anything worth showing on
    # the dashboard — soonest first, without loading the whole larder.
    scope :expiring, -> { where(expires_on: ..(Date.current + SOON_DAYS)).order(:expires_on) }
  end

  def expiration_status
    return :none if expires_on.blank?

    days_left = (expires_on - Date.current).to_i
    if days_left.negative?
      :expired
    elsif days_left <= URGENT_DAYS
      :destructive
    elsif days_left <= SOON_DAYS
      :soon
    else
      :ok
    end
  end
end
