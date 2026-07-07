class RecipeCatalogController < ApplicationController
  PER_PAGE = 24

  # "Découvrir" tab of the Recipes module: browse the read-only recipe
  # catalog and clone entries into the household's own book (Spec §9.5).
  def index
    @query = params[:q].to_s.strip
    entries = RecipeCatalogEntry.ordered
    entries = entries.search(@query) if @query.present?

    @page = [ params[:page].to_i, 1 ].max
    @per_page = PER_PAGE
    @total = entries.count
    @entries = entries.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # Clones a catalog entry into the current household's recipe book
  # (Recipes::Catalog::AddToHousehold), then redirects to the new recipe —
  # from there, every existing Recipes feature (shopping list export, menu
  # planning, editing) works unmodified.
  def add_to_household
    entry = RecipeCatalogEntry.find(params[:id])
    recipe = Recipes::Catalog::AddToHousehold.call(entry: entry, household: Current.household)
    redirect_to recipe, notice: t(".notice")
  end
end
