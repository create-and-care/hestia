class BudgetCategoriesController < ApplicationController
  def create
    Current.household.budget_categories.create(category_params)
    redirect_to budget_path
  end

  def destroy
    Current.household.budget_categories.find(params[:id]).destroy
    redirect_to budget_path, notice: "Catégorie supprimée."
  end

  private
    def category_params
      params.require(:budget_category).permit(:kind, :name, :emoji, :color)
    end
end
