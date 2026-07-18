class PublicGiftListsController < ApplicationController
  # Public unauthenticated access via token (Spec §5, point 2 / §12.1).
  allow_unauthenticated_access
  allow_without_household
  before_action :set_shared_list

  def show
    @ideas = @list.gift_ideas.ordered.includes(:gift_reservations, photo_attachment: :blob)
  end

  def reserve
    idea = @list.gift_ideas.find(params[:idea_id])
    reservation = idea.gift_reservations.new(reserver_name: params[:reserver_name])

    if reservation.save
      cookies.permanent.signed[reservation_cookie_key(idea)] = reservation.token
    end

    redirect_to public_gift_list_path(@share.token)
  end

  # Only the browser that made the reservation (identified by the signed
  # cookie handed out in #reserve) can cancel it — anyone with the public
  # link would otherwise be able to cancel anyone else's reservation.
  def unreserve
    idea = @list.gift_ideas.find(params[:idea_id])
    reservation = idea.gift_reservations.find_by(token: cookies.signed[reservation_cookie_key(idea)])

    if reservation
      reservation.destroy
      cookies.delete(reservation_cookie_key(idea))
      redirect_to public_gift_list_path(@share.token)
    else
      redirect_to public_gift_list_path(@share.token), alert: t(".not_authorized")
    end
  end

  private
    def set_shared_list
      @share = GiftListShare.find_by!(token: params[:token])
      @list = @share.gift_list
    end

    def reservation_cookie_key(idea)
      "gift_reservation_#{idea.id}"
    end
end
