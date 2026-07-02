class BudgetController < ApplicationController
  def show
    @period = params[:period] == "annual" ? :annual : :monthly
    @categories = Current.household.budget_categories.ordered.includes(:budget_entries)
    @envelopes = Current.household.savings_envelopes.ordered
    @projects = Current.household.shared_projects.ordered
    @summary = Budget::Summary.call(household: Current.household, period: @period)
    @category = Current.household.budget_categories.new
    @envelope = Current.household.savings_envelopes.new
  end
end
