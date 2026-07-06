class TaskCategoriesController < ApplicationController
  def create
    Current.household.task_categories.create(name: params.dig(:task_category, :name))
    redirect_to tasks_path
  end

  def destroy
    Current.household.task_categories.find(params[:id]).destroy
    redirect_to tasks_path, notice: t(".notice")
  end
end
