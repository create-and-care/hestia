module RecipeViewMode
  extend ActiveSupport::Concern

  MODES = %w[card list].freeze

  private
    # Card vs list display for the Recipes/Découvrir tabs, remembered across
    # visits (no schema change needed for a purely cosmetic preference).
    def recipe_view_mode
      mode = params[:view].presence || session[:recipe_view_mode] || "card"
      mode = "card" unless MODES.include?(mode)
      session[:recipe_view_mode] = mode
      mode
    end
end
