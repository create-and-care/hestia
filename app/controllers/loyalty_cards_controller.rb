class LoyaltyCardsController < ApplicationController
  before_action :set_card, only: %i[show edit update destroy]

  def index
    @cards = Current.household.loyalty_cards.ordered
  end

  def show
  end

  def new
    @card = Current.household.loyalty_cards.new
  end

  def create
    @card = Current.household.loyalty_cards.new(card_params)
    if @card.save
      redirect_to loyalty_cards_path, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      redirect_to loyalty_cards_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to loyalty_cards_path, notice: t(".deleted")
  end

  def reorder
    Reordering.apply(Current.household.loyalty_cards, params[:ids])
    head :no_content
  end

  private
    def set_card
      @card = Current.household.loyalty_cards.find(params[:id])
    end

    def card_params
      params.require(:loyalty_card).permit(:name, :number, :code_format, :position, :loyalty_brand_id)
    end
end
