require "uri"

module ApplicationHelper
  # Returns the URL only if it's a valid http(s) URL, nil otherwise — prevents
  # injecting a dangerous scheme (e.g. javascript:) into an external link's href.
  def safe_url(url)
    parsed = URI.parse(url.to_s)
    url if parsed.is_a?(URI::HTTP) && parsed.host.present?
  rescue URI::InvalidURIError
    nil
  end

  # Standard "Dashboard / Module" breadcrumb shown above every module view,
  # reusing dashboard.show.nav.* so a module's display name has one source of
  # truth (SidebarHelper::SIDEBAR_GROUPS). Pass extra [label, path] pairs for
  # sub-pages between the module and the current page (path nil = current).
  def module_breadcrumb(nav_key, *extra_items, module_path: nil)
    items = [ [ t("common.dashboard"), root_path ] ]
    items << [ t("dashboard.show.nav.#{nav_key}"), extra_items.empty? ? nil : module_path ]
    items.concat(extra_items)
    render Ui::BreadcrumbComponent.new(items: items)
  end
end
