class CirclePostReactionsController < ApplicationController
  before_action :set_post

  def create
    reaction = @post.circle_post_reactions.find_or_initialize_by(user: Current.user)
    reaction.update(emoji: params[:emoji])
    redirect_to @post.circle
  end

  def destroy
    @post.circle_post_reactions.where(user: Current.user).destroy_all
    redirect_to @post.circle
  end

  private
    # The post must belong to a circle the user is a member of.
    def set_post
      @post = CirclePost.joins(circle: :circle_memberships)
        .where(circle_memberships: { user_id: Current.user.id })
        .find(params[:id])
    end
end
