class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications.recent.limit(50)
  end

  def mark_read
    Current.user.notifications.find(params[:id]).mark_read!
    redirect_back fallback_location: notifications_path
  end

  def mark_all_read
    Current.user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path
  end
end
