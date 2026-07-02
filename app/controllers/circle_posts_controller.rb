class CirclePostsController < ApplicationController
  before_action :set_circle

  def create
    @circle.circle_posts.create(author: Current.user, body: params.require(:circle_post)[:body])
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @circle }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @circle
  end

  def destroy
    post = @circle.circle_posts.find(params[:id])
    post.destroy if post.deletable_by?(Current.user)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(post) }
      format.html { redirect_to @circle }
    end
  end

  private
    def set_circle
      @circle = Current.user.circles.find(params[:circle_id])
    end
end
