class MealPlanEntriesController < ApplicationController
  before_action :set_entry, only: %i[update destroy]

  def create
    @entry = Current.household.meal_plan_entries.new(entry_params)
    @entry.recipe = scoped_recipe
    if @entry.save
      redirect_to menu_path(week: @entry.on_date)
    else
      redirect_to menu_path, alert: @entry.errors.full_messages.to_sentence
    end
  end

  def update
    @entry.assign_attributes(entry_params)
    @entry.recipe = scoped_recipe
    @entry.save
    redirect_to menu_path(week: @entry.on_date)
  end

  def destroy
    @entry.destroy
    redirect_to menu_path(week: @entry.on_date)
  end

  private
    def set_entry
      @entry = Current.household.meal_plan_entries.find(params[:id])
    end

    def entry_params
      params.require(:meal_plan_entry).permit(:on_date, :meal_type, :free_name, :position)
    end

    def scoped_recipe
      id = params.dig(:meal_plan_entry, :recipe_id)
      Current.household.recipes.find_by(id: id) if id.present?
    end
end
