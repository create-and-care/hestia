class RecipesController < ApplicationController
  include RecipeViewMode

  layout "minimal", only: :cook

  before_action :set_recipe, only: %i[show edit update destroy cook add_to_shopping_list link_note link_bottle]

  PER_PAGE = 24

  def index
    @query = params[:q].to_s.strip
    @category = params[:category].to_s.strip
    @servings = params[:servings].to_s.strip
    @tag = params[:tag].to_s.strip
    @categories = Current.household.recipes.distinct.where.not(category: [ nil, "" ]).order(:category).pluck(:category)
    @servings_options = Current.household.recipes.distinct.where.not(servings: nil).order(:servings).pluck(:servings)
    @tags = Current.household.recipes.pluck(Arel.sql("DISTINCT unnest(tags)")).compact.sort
    @view_mode = recipe_view_mode

    recipes = Current.household.recipes.ordered.includes(photo_attachment: :blob)
    recipes = recipes.where("title ILIKE ?", "%#{@query}%") if @query.present?
    recipes = recipes.where(category: @category) if @category.present?
    recipes = recipes.where(servings: @servings) if @servings.present?
    recipes = recipes.where("? = ANY(tags)", @tag) if @tag.present?

    @per_page = PER_PAGE
    @total = recipes.count
    @total_pages = [ (@total / @per_page.to_f).ceil, 1 ].max
    @page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    @recipes = recipes.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @linkable_notes = Current.household.notes.general.where(recipe_id: nil).order(:title)
    @linkable_bottles = Current.household.bottles.where(recipe_id: nil).order(:name)
    @shopping_lists = Current.household.shopping_lists.general.order(:name)
  end

  def new
    @recipe = Current.household.recipes.new
  end

  def create
    @recipe = Current.household.recipes.new(recipe_params)
    apply_text_fields(@recipe)

    if @recipe.save
      redirect_to @recipe, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @recipe.assign_attributes(recipe_params)
    apply_text_fields(@recipe)

    if @recipe.save
      redirect_to @recipe, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: t(".deleted")
  end

  # Full-screen reading mode for cooking.
  def cook
  end

  # Export ingredients to the shopping list (Recipes → Shopping interconnection).
  # A recipe's ingredients are only exported once per list: a repeat click
  # reports that they're already there instead of piling up duplicate items.
  def add_to_shopping_list
    list = target_shopping_list

    if list.items.exists?(recipe_id: @recipe.id)
      flash[:notice] = t(".already_notice")
    else
      Recipes::AddIngredientsToShoppingList.call(recipe: @recipe, shopping_list: list)
      flash[:notice] = t(".notice")
    end

    # A plain id, not a rendered link: flash values round-trip through the
    # session (JSON), which would silently strip any html_safe marking on a
    # pre-built <a> string — the view builds the actual link itself instead.
    flash[:shopping_list_id] = list.id
    redirect_to @recipe
  end

  # Notes/Wine Cellar interconnections: link an existing note
  # or bottle to this recipe (a tasting note, a wine pairing…).
  def link_note
    note = Current.household.notes.general.find(params[:note_id])
    note.update!(recipe: @recipe)
    redirect_to @recipe, notice: t(".notice")
  end

  def link_bottle
    bottle = Current.household.bottles.find(params[:bottle_id])
    bottle.update!(recipe: @recipe)
    redirect_to @recipe, notice: t(".notice")
  end

  # Import form from a URL.
  def new_import
  end

  def import
    recipe = Recipes::ImportFromUrl.call(household: Current.household, url: params[:url])

    if recipe
      redirect_to recipe, notice: t(".notice")
    else
      flash.now[:alert] = t(".alert")
      render :new_import, status: :unprocessable_entity
    end
  end

  private
    def set_recipe
      @recipe = Current.household.recipes.find(params[:id])
    end

    def target_shopping_list
      if params[:shopping_list_id].present?
        Current.household.shopping_lists.find(params[:shopping_list_id])
      else
        Current.household.shopping_lists.order(:created_at).first ||
          Current.household.shopping_lists.create!(name: t("shopping_lists.default_list_name"))
      end
    end

    def recipe_params
      params.require(:recipe).permit(:title, :category, :prep_time_minutes, :cook_time_minutes, :servings, :source_url, :photo)
    end

    def apply_text_fields(recipe)
      recipe.tags = params.dig(:recipe, :tags_text).to_s.split(",").map(&:strip).reject(&:blank?)
      recipe.recipe_ingredients = build_lines(params.dig(:recipe, :ingredients_text)) do |line, index|
        RecipeIngredient.new(name: line, position: index)
      end
      recipe.recipe_steps = build_lines(params.dig(:recipe, :steps_text)) do |line, index|
        RecipeStep.new(content: line, position: index)
      end
    end

    def build_lines(text)
      text.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?).each_with_index.map do |line, index|
        yield(line, index)
      end
    end
end
