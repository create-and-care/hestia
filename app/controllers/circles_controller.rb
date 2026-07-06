class CirclesController < ApplicationController
  before_action :set_circle, only: :show

  def index
    @circles = Current.user.circles.order(:name)
    @circle = Circle.new
  end

  def show
    @posts = @circle.circle_posts.chronological.includes(:author, :circle_post_reactions)
    @post = @circle.circle_posts.new
  end

  def create
    @circle = Circle.new(circle_params)
    if @circle.save
      @circle.circle_memberships.create!(user: Current.user, role: "admin")
      redirect_to @circle
    else
      redirect_to circles_path, alert: @circle.errors.full_messages.to_sentence
    end
  end

  private
    # Access by circle membership — never by household (architecture deviation).
    def set_circle
      @circle = Current.user.circles.find(params[:id])
    end

    def circle_params
      params.require(:circle).permit(:name, :theme)
    end
end
