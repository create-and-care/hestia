class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy cook add_to_shopping_list]

  def index
    @query = params[:q].to_s.strip
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
      redirect_to @recipe, notice: "Recette créée."
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
      redirect_to @recipe, notice: "Recette mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: "Recette supprimée."
  end

  # Mode lecture plein écran pour cuisiner.
  def cook
  end

  # Export des ingrédients vers la liste de courses (interconnexion Recettes → Courses).
  def add_to_shopping_list
    Recipes::AddIngredientsToShoppingList.call(recipe: @recipe, shopping_list: target_shopping_list)
    redirect_to @recipe, notice: "Ingrédients ajoutés à la liste de courses."
  end

  # Formulaire d'import depuis une URL.
  def new_import
  end

  def import
    recipe = Recipes::ImportFromUrl.call(household: Current.household, url: params[:url])

    if recipe
      redirect_to recipe, notice: "Recette importée."
    else
      flash.now[:alert] = "Impossible d'importer cette recette (page injoignable ou sans microdonnées)."
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
