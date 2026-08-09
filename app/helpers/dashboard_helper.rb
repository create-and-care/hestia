module DashboardHelper
  def dashboard_member_avatars(memberships)
    memberships.map do |membership|
      name = membership.user.name.presence || membership.user.email_address
      { alt: name, label: "#{name} (#{membership.admin? ? t('dashboard.show.admin') : t('dashboard.show.member')})", tint: membership.user.avatar_tint }
    end
  end
end
