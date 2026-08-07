class PublicGiftListsController < ApplicationController
  # Public unauthenticated access via token.
  allow_unauthenticated_access
  allow_without_household

  # The only routes in the app that are both unauthenticated and guarded by
  # nothing but a secret in the URL, so they are also the only ones where an
  # attacker can look for a valid token by trying tokens. Two limits, because
  # the two risks have different shapes:
  #
  #   browse — every action, generous. Aimed at token enumeration, which needs
  #            volume; a real family opening the same list a few times over,
  #            possibly from behind one NAT address, must not trip it.
  #   write  — the state-changing pair, tight, mirroring the `to: 10,
  #            within: 3.minutes` already on the three authentication entries.
  #
  # Both count through the controller cache store (Solid Cache in production).
  rate_limit to: 60, within: 1.minute, name: "public-gift-browse"
  rate_limit to: 10, within: 3.minutes, name: "public-gift-write", only: %i[reserve unreserve]

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
