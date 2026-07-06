class PublicGiftListsController < ApplicationController
  # Public unauthenticated access via token (Spec §5, point 2 / §12.1).
  allow_unauthenticated_access
  allow_without_household
  before_action :set_shared_list

  def show
    @ideas = @list.gift_ideas.ordered.includes(:gift_reservations)
  end

  def reserve
    idea = @list.gift_ideas.find(params[:idea_id])
    idea.gift_reservations.create(reserver_name: params[:reserver_name])
    redirect_to public_gift_list_path(@share.token)
  end

  def unreserve
    idea = @list.gift_ideas.find(params[:idea_id])
    idea.gift_reservations.destroy_all
    redirect_to public_gift_list_path(@share.token)
  end

  private
    def set_shared_list
      @share = GiftListShare.find_by!(token: params[:token])
      @list = @share.gift_list
    end
end
