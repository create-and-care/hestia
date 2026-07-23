class TaskCategoriesController < ApplicationController
  def create
    Current.household.task_categories.create(name: params.dig(:task_category, :name))
    redirect_to tasks_path
  end

  def destroy
    category = Current.household.task_categories.find(params[:id])
    if category.tasks.where(done: false).exists?
      redirect_to tasks_path, alert: t(".pending_tasks_alert")
    else
      category.destroy
      redirect_to tasks_path, notice: t(".notice")
    end
  end
end
