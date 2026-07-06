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
end
