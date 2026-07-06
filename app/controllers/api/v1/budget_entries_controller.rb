module Api
  module V1
    class BudgetEntriesController < BaseController
      def index
        render json: paginate(scoped_entries.order(:created_at)).map { |entry| serialize(entry) }
      end

      def create
        category = Current.household.budget_categories.find(params[:budget_category_id])
        entry = category.budget_entries.create!(entry_params)
        render json: serialize(entry), status: :created
      end

      private
        def scoped_entries
          BudgetEntry.joins(:budget_category).where(budget_categories: { household_id: Current.household.id })
        end

        def entry_params
          params.permit(:name, :amount, :periodicity)
        end

        def serialize(entry)
          entry.as_json(only: %i[id name amount periodicity budget_category_id]).merge(monthly_amount: entry.monthly_amount)
        end
    end
  end
end
