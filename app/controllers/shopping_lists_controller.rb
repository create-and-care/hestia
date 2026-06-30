class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: %i[show destroy]

  def index
    @shopping_lists = Current.household.shopping_lists.order(:name)
  end

  def show
    @item = ShoppingListItem.new
  end

  def new
    @shopping_list = Current.household.shopping_lists.build
  end

  def create
    @shopping_list = Current.household.shopping_lists.build(shopping_list_params)

    if @shopping_list.save
      redirect_to @shopping_list, notice: "Liste créée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list.destroy
    redirect_to shopping_lists_path, notice: "Liste supprimée."
  end

  private
    def set_shopping_list
      @shopping_list = Current.household.shopping_lists.find(params[:id])
    end

    def shopping_list_params
      params.require(:shopping_list).permit(:name, :icon)
    end
end
