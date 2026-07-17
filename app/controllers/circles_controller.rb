class CirclesController < ApplicationController
  before_action :set_circle, only: %i[show edit update destroy regenerate_invite_code]
  before_action :require_admin!, only: %i[edit update destroy regenerate_invite_code]

  def index
    @circles = Current.user.circles.order(:name)
    @circle = Circle.new
  end

  def show
    @page = [ params[:page].to_i, 1 ].max
    posts_scope = @circle.circle_posts.chronological.includes(:author, :circle_post_reactions, photo_attachment: :blob)
    @posts = posts_scope.offset((@page - 1) * CirclePost::PAGE_SIZE).limit(CirclePost::PAGE_SIZE)
    @has_more = @circle.circle_posts.count > @page * CirclePost::PAGE_SIZE
    @post = @circle.circle_posts.new
    @my_membership = @circle.circle_memberships.find_by(user: Current.user)
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

  def edit
  end

  def update
    if @circle.update(circle_params)
      redirect_to @circle, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @circle.destroy
    redirect_to circles_path, notice: t(".deleted")
  end

  def regenerate_invite_code
    @circle.update!(invite_code: Circle.generate_invite_code)
    redirect_to @circle, notice: t(".regenerated")
  end

  private
    # Access by circle membership — never by household (architecture deviation).
    def set_circle
      @circle = Current.user.circles.find(params[:id])
    end

    def require_admin!
      redirect_to @circle, alert: t("circles.not_admin") unless @circle.admin?(Current.user)
    end

    def circle_params
      params.require(:circle).permit(:name, :theme)
    end
end
