module CollectionViewMode
  extend ActiveSupport::Concern

  MODES = %w[list grid].freeze

  private
    # List vs grid display for a collection view, remembered per-scope across
    # visits (session), falling back to the household's default (Global recette item).
    # `param:` lets a page host more than one independent toggle (e.g. two
    # collections on the same view) without them clobbering each other's query param.
    def collection_view_mode(scope, param: :view)
      key = :"#{scope}_view_mode"
      mode = params[param].presence || session[key] || Current.household&.default_view
      mode = "list" unless MODES.include?(mode)
      session[key] = mode
      mode
    end
end
