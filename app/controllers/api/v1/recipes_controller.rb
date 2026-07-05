module Api
  module V1
    class RecipesController < BaseController
      def index
        render json: paginate(Current.household.recipes.ordered).map { |recipe| serialize(recipe) }
      end

      def show
        render json: serialize(Current.household.recipes.find(params[:id]), full: true)
      end

      private
        def serialize(recipe, full: false)
          data = recipe.as_json(only: %i[id title prep_time_minutes cook_time_minutes servings category tags])
          if full
            data["ingredients"] = recipe.recipe_ingredients.map { |i| i.as_json(only: %i[id name quantity unit]) }
            data["steps"] = recipe.recipe_steps.map { |s| s.as_json(only: %i[id position content]) }
          end
          data
        end
    end
  end
end
