require "uri"

module ApplicationHelper
  # Retourne l'URL seulement si c'est une URL http(s) valide, sinon nil — empêche
  # l'injection d'un schéma dangereux (ex. javascript:) dans un href de lien externe.
  def safe_url(url)
    parsed = URI.parse(url.to_s)
    url if parsed.is_a?(URI::HTTP) && parsed.host.present?
  rescue URI::InvalidURIError
    nil
  end
end
