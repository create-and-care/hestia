module CollectionViewMode
  extend ActiveSupport::Concern

  MODES = %w[list grid].freeze

  private
    # List vs grid display for a collection view, remembered per-scope across
    # visits (session), falling back to the household's default (Global recette item).
    def collection_view_mode(scope)
      key = :"#{scope}_view_mode"
      mode = params[:view].presence || session[key] || Current.household&.default_view
      mode = "list" unless MODES.include?(mode)
      session[key] = mode
      mode
    end
end
