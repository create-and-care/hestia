class BudgetEntriesController < ApplicationController
  def create
    category = Current.household.budget_categories.find(params.dig(:budget_entry, :budget_category_id))
    category.budget_entries.create(entry_params)
    redirect_to budget_path
  end

  def destroy
    scoped_entries.find(params[:id]).destroy
    redirect_to budget_path
  end

  private
    def scoped_entries
      BudgetEntry.joins(:budget_category).where(budget_categories: { household_id: Current.household.id })
    end

    def entry_params
      params.require(:budget_entry).permit(:name, :amount, :periodicity)
    end
end
