class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications.recent.limit(50)
    @notifications_by_block = @notifications.group_by(&:block_key)
  end

  def mark_read
    @notification = Current.user.notifications.find(params[:id])
    @notification.mark_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: notifications_path }
    end
  end

  def mark_all_read
    @notifications = Current.user.notifications.unread.to_a
    @notifications.each(&:mark_read!)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: notifications_path }
    end
  end
end
