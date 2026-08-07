class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: %i[show destroy]

  def index
    # Each card shows its list's item count (PERF-06).
    @shopping_lists = Current.household.shopping_lists.general.order(:name).includes(:items)
  end

  def show
    @item = ShoppingListItem.new
    respond_to do |format|
      format.html
      format.pdf do
        send_data Pdf::ShoppingListDocument.new(@shopping_list).render,
          filename: "#{@shopping_list.name.parameterize}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def new
    @shopping_list = Current.household.shopping_lists.build
  end

  def create
    @shopping_list = Current.household.shopping_lists.build(shopping_list_params)

    if @shopping_list.save
      redirect_to @shopping_list, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list.destroy
    redirect_to shopping_lists_path, notice: t(".deleted")
  end

  private
    def set_shopping_list
      @shopping_list = Current.household.shopping_lists.find(params[:id])
    end

    def shopping_list_params
      params.require(:shopping_list).permit(:name, :icon)
    end
end
