class SharedExpensesController < ApplicationController
  before_action :set_project
  before_action :set_expense, only: %i[edit update destroy]

  def create
    expense = @project.shared_expenses.new(expense_params)
    if expense.save
      redirect_to @project
    else
      redirect_to @project, alert: expense.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @expense.update(expense_params)
      redirect_to @project, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to @project, notice: t(".deleted")
  end

  private
    def set_project
      @project = Current.household.shared_projects.find(params[:shared_project_id])
    end

    def set_expense
      @expense = @project.shared_expenses.find(params[:id])
    end

    def expense_params
      params.require(:shared_expense).permit(:amount, :description, :spent_on, :shared_project_participant_id)
    end
end
