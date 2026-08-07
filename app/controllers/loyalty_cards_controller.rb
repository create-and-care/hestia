class LoyaltyCardsController < ApplicationController
  include CollectionViewMode

  layout "minimal", only: :kiosk

  before_action :set_card, only: %i[show edit update destroy kiosk move_up move_down]

  def index
    # Each card renders its brand's logo and colour (PERF-06).
    @cards = Current.household.loyalty_cards.ordered.includes(:loyalty_brand)
    @view_mode = collection_view_mode(:loyalty_cards)
  end

  def show
  end

  # Full-screen, sidebar-free presentation for scanning at checkout — the module's actual
  # value proposition, previously only a regular page with the sidebar still showing.
  def kiosk
  end

  def new
    @card = Current.household.loyalty_cards.new
    @addresses = Current.household.addresses.order(:name)
  end

  def create
    @card = Current.household.loyalty_cards.new(card_params)
    if @card.save
      redirect_to loyalty_cards_path, notice: t(".created")
    else
      @addresses = Current.household.addresses.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @addresses = Current.household.addresses.order(:name)
  end

  def update
    if @card.update(card_params)
      redirect_to loyalty_cards_path, notice: t(".updated")
    else
      @addresses = Current.household.addresses.order(:name)
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

  def move_up
    swap_with_sibling(-1)
    redirect_to loyalty_cards_path
  end

  def move_down
    swap_with_sibling(1)
    redirect_to loyalty_cards_path
  end

  private
    def set_card
      @card = Current.household.loyalty_cards.find(params[:id])
    end

    def card_params
      params.require(:loyalty_card).permit(:name, :number, :code_format, :position, :loyalty_brand_id, :address_id)
    end

    def swap_with_sibling(direction)
      siblings = Current.household.loyalty_cards.ordered.to_a
      index = siblings.index(@card)
      sibling = siblings[index + direction] if index && (index + direction).between?(0, siblings.size - 1)
      return unless sibling

      @card.position, sibling.position = sibling.position, @card.position
      @card.save!
      sibling.save!
    end
end
