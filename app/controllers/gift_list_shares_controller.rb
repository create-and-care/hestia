class GiftListSharesController < ApplicationController
  before_action :set_list

  def create
    @list.create_gift_list_share unless @list.gift_list_share
    redirect_to @list, notice: "Lien de partage activé."
  end

  def destroy
    @list.gift_list_share&.destroy
    redirect_to @list, notice: "Lien de partage désactivé."
  end

  private
    def set_list
      @list = Current.household.gift_lists.find(params[:gift_list_id])
    end
end
