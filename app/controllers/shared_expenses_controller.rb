class SharedExpensesController < ApplicationController
  before_action :set_project

  def create
    @project.shared_expenses.create(expense_params)
    redirect_to @project
  end

  def destroy
    @project.shared_expenses.find(params[:id]).destroy
    redirect_to @project
  end

  private
    def set_project
      @project = Current.household.shared_projects.find(params[:shared_project_id])
    end

    def expense_params
      params.require(:shared_expense).permit(:amount, :description, :spent_on, :shared_project_participant_id)
    end
end
