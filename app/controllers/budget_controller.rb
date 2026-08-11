class BudgetController < ApplicationController
  def show
    @period = params[:period] == "annual" ? :annual : :monthly
    # :documents as well as :budget_entries — each category line shows how many
    # documents are attached to it (PERF-06, found by BULLET_RAISE=1).
    @categories = Current.household.budget_categories.ordered.includes(:budget_entries, :documents)
    @envelopes = Current.household.savings_envelopes.ordered
    @projects = Current.household.shared_projects.ordered
    @summary = Budget::Summary.call(household: Current.household, period: @period)
    @expense_chart_data = Budget::ExpenseChartData.call(categories: @categories, period: @period)
    @category = Current.household.budget_categories.new
    @envelope = Current.household.savings_envelopes.new
  end
end
