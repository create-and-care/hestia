class RecipeCatalogController < ApplicationController
  include RecipeViewMode

  PER_PAGE = 24

  # "Découvrir" tab of the Recipes module: browse the read-only recipe
  # catalog and clone entries into the household's own book.
  def index
    @query = params[:q].to_s.strip
    @tag = params[:tag].to_s.strip
    @tags = RecipeCatalogEntry.all_tags
    @view_mode = recipe_view_mode

    entries = RecipeCatalogEntry.ordered
    entries = entries.search(@query) if @query.present?
    entries = entries.tagged(@tag) if @tag.present?

    @per_page = PER_PAGE
    @total = entries.count
    @total_pages = [ (@total / @per_page.to_f).ceil, 1 ].max
    @page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    @entries = entries.offset((@page - 1) * @per_page).limit(@per_page)
    @added_entry_ids = Current.household.recipes.where.not(recipe_catalog_entry_id: nil).pluck(:recipe_catalog_entry_id).to_set
  end

  # Body of the preview dialog, rendered into a lazy turbo-frame on the card.
  # The catalog is global rather than household-scoped, so there is nothing to
  # authorize here beyond being signed in — which ApplicationController covers.
  def preview
    @entry = RecipeCatalogEntry.find(params[:id])
    @already_added = Current.household.recipes.exists?(recipe_catalog_entry_id: @entry.id)
    render partial: "recipe_catalog/preview", locals: { entry: @entry, already_added: @already_added }
  end

  # Clones a catalog entry into the current household's recipe book
  # (Recipes::Catalog::AddToHousehold), then redirects to the new recipe —
  # from there, every existing Recipes feature (shopping list export, menu
  # planning, editing) works unmodified. A second click (or a replayed
  # request) redirects to the already-cloned recipe instead of duplicating it.
  def add_to_household
    entry = RecipeCatalogEntry.find(params[:id])
    existing = Current.household.recipes.find_by(recipe_catalog_entry_id: entry.id)

    if existing
      redirect_to existing, notice: t(".already_notice")
    else
      recipe = Recipes::Catalog::AddToHousehold.call(entry: entry, household: Current.household)
      redirect_to recipe, notice: t(".notice")
    end
  end
end
