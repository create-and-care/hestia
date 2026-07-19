class BudgetCategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def create
    category = Current.household.budget_categories.new(category_params)
    if category.save
      redirect_to budget_path
    else
      redirect_to budget_path, alert: category.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to budget_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to budget_path, notice: t(".deleted")
  end

  private
    def set_category
      @category = Current.household.budget_categories.find(params[:id])
    end

    def category_params
      params.require(:budget_category).permit(:kind, :name, :emoji, :color)
    end
end
