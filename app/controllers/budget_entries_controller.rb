class BudgetEntriesController < ApplicationController
  before_action :set_entry, only: %i[edit update destroy]

  def create
    category = Current.household.budget_categories.find(params.dig(:budget_entry, :budget_category_id))
    entry = category.budget_entries.new(entry_params)
    if entry.save
      redirect_to budget_path
    else
      redirect_to budget_path, alert: entry.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to budget_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to budget_path, notice: t(".deleted")
  end

  private
    def set_entry
      @entry = scoped_entries.find(params[:id])
    end

    def scoped_entries
      BudgetEntry.joins(:budget_category).where(budget_categories: { household_id: Current.household.id })
    end

    def entry_params
      params.require(:budget_entry).permit(:name, :amount, :periodicity)
    end
end
