# Expiration status of a record with an `expires_on` column.
# Computed server-side from the current date (never fixed at creation time),
# to stay correct without any action from the user.
module Perishable
  extend ActiveSupport::Concern

  def expiration_status
    return :none if expires_on.blank?

    days_left = (expires_on - Date.current).to_i
    if days_left.negative?
      :expired
    elsif days_left <= 1
      :urgent   # overdue today / tomorrow
    elsif days_left <= 3
      :soon     # 2 to 3 days
    else
      :ok       # beyond that
    end
  end
end
