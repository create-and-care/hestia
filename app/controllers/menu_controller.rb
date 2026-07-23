class MenuController < ApplicationController
  # Weekly meal plan.
  def show
    @week_start = parse_monday
    @days = (@week_start..(@week_start + 6.days)).to_a
    @entries = Current.household.meal_plan_entries
      .general
      .where(on_date: @week_start..(@week_start + 6.days))
      .includes(:recipe)
      .ordered
      .group_by(&:on_date)
    @shopping_lists = Current.household.shopping_lists.general.order(:name)
  end

  # Menu → Shopping interconnection: exports the ingredients of
  # every recipe planned this week to the household's shopping list. Reuses
  # Recipes::AddIngredientsToShoppingList (already Recipes' own "add to
  # shopping list" action) rather than duplicating the export logic, and
  # skips a recipe already exported so repeat clicks don't pile up duplicates.
  def add_ingredients
    week_start = parse_monday
    recipes = Current.household.meal_plan_entries
      .where(on_date: week_start..(week_start + 6.days))
      .where.not(recipe_id: nil)
      .includes(:recipe).map(&:recipe).uniq

    list = target_shopping_list
    new_recipes = recipes.reject { |recipe| list.items.exists?(recipe_id: recipe.id) }
    new_recipes.each { |recipe| Recipes::AddIngredientsToShoppingList.call(recipe: recipe, shopping_list: list) }

    if new_recipes.any?
      flash[:notice] = t(".notice", count: new_recipes.size)
    else
      flash[:already_notice] = true
    end
    flash[:shopping_list_id] = list.id
    redirect_to menu_path(week: week_start)
  end

  private
    def parse_monday
      base = begin
        Date.parse(params[:week])
      rescue ArgumentError, TypeError
        Date.current
      end
      base.beginning_of_week
    end

    def target_shopping_list
      if params[:shopping_list_id].present?
        Current.household.shopping_lists.find(params[:shopping_list_id])
      else
        Current.household.shopping_lists.order(:created_at).first ||
          Current.household.shopping_lists.create!(name: t("shopping_lists.default_list_name"))
      end
    end
end
