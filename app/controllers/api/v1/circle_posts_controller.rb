module Api
  module V1
    class CirclePostsController < BaseController
      before_action :set_circle

      def index
        render json: paginate(@circle.circle_posts.chronological).map { |post| serialize(post) }
      end

      def create
        post = @circle.circle_posts.create!(author: Current.user, body: params[:body])
        render json: serialize(post), status: :created
      end

      private
        # Access by circle membership, never by household — Circle is an
        # architectural deviation from the standard household scoping.
        def set_circle
          @circle = Current.user.circles.find(params[:circle_id])
        end

        def serialize(post)
          post.as_json(only: %i[id body author_id circle_id created_at])
        end
    end
  end
end
