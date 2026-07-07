class RecipesController < ApplicationController
  include RecipeViewMode

  before_action :set_recipe, only: %i[show edit update destroy cook add_to_shopping_list]

  def index
    @query = params[:q].to_s.strip
    @view_mode = recipe_view_mode
    recipes = Current.household.recipes.ordered
    recipes = recipes.where("title ILIKE ?", "%#{@query}%") if @query.present?
    @recipes = recipes
  end

  def show
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
      redirect_to @recipe, notice: t(".already_notice")
    else
      Recipes::AddIngredientsToShoppingList.call(recipe: @recipe, shopping_list: list)
      redirect_to @recipe, notice: t(".notice")
    end
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
      Current.household.shopping_lists.order(:created_at).first ||
        Current.household.shopping_lists.create!(name: "Courses")
    end

    def recipe_params
      params.require(:recipe).permit(:title, :category, :prep_time_minutes, :cook_time_minutes, :servings, :source_url)
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
