class MealPlanEntriesController < ApplicationController
  before_action :set_entry, only: %i[edit update destroy]

  def create
    @entry = Current.household.meal_plan_entries.new(entry_params)
    @entry.recipe = scoped_recipe
    if @entry.save
      redirect_to menu_path(week: @entry.on_date)
    else
      redirect_to menu_path, alert: @entry.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    @entry.assign_attributes(entry_params)
    # Only touch the recipe association when the client actually submitted a
    # recipe_id: otherwise a partial update (e.g. just meal_type) would wipe
    # out an existing recipe and silently fail validation.
    @entry.recipe = scoped_recipe if params[:meal_plan_entry].key?(:recipe_id)
    if @entry.save
      redirect_to menu_path(week: @entry.on_date), notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to menu_path(week: @entry.on_date), notice: t(".deleted")
  end

  # Drag-and-drop reordering within a day (Reordering already backs
  # Shopping/Tasks/Loyalty). Moving a meal to a *different* day is done via
  # #update (the edit form) rather than cross-list drag: sortable_controller.js
  # has no shared-group support today, and verifying cross-list drag behavior
  # would require a running browser (system test), which this app's test
  # suite deliberately does not exercise.
  def reorder
    Reordering.apply(Current.household.meal_plan_entries, params[:ids])
    head :no_content
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
