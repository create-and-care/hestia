module Api
  module V1
    class MealPlanEntriesController < BaseController
      def index
        render json: paginate(Current.household.meal_plan_entries.ordered).map { |entry| serialize(entry) }
      end

      def create
        entry = Current.household.meal_plan_entries.new(entry_attrs)
        entry.recipe = scoped_recipe
        entry.save!
        render json: serialize(entry), status: :created
      end

      private
        # `position` defaults at the database level; only override it when the
        # client explicitly supplies one (mirrors reorder-style optional params elsewhere).
        def entry_attrs
          attrs = { on_date: params[:on_date], meal_type: params[:meal_type], free_name: params[:free_name] }
          attrs[:position] = params[:position] if params[:position].present?
          attrs
        end

        def scoped_recipe
          Current.household.recipes.find_by(id: params[:recipe_id]) if params[:recipe_id].present?
        end

        def serialize(entry)
          entry.as_json(only: %i[id on_date meal_type free_name position recipe_id]).merge(display_name: entry.display_name)
        end
    end
  end
end
