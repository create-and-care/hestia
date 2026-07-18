class CirclePostsController < ApplicationController
  before_action :set_circle

  def create
    @circle.circle_posts.create!(circle_post_params.merge(author: Current.user))
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @circle }
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @circle, alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    post = @circle.circle_posts.find(params[:id])

    if post.deletable_by?(Current.user)
      post.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(post) }
        format.html { redirect_to @circle }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to @circle, alert: t(".not_authorized") }
      end
    end
  end

  private
    def set_circle
      @circle = Current.user.circles.find(params[:circle_id])
    end

    def circle_post_params
      params.require(:circle_post).permit(:body, :photo)
    end
end
