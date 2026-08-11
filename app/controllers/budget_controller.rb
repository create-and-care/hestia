class BudgetController < ApplicationController
  def show
    @period = params[:period] == "annual" ? :annual : :monthly
    # :documents as well as :budget_entries — each category line shows how many
    # documents are attached to it (PERF-06, found by BULLET_RAISE=1).
    @categories = Current.household.budget_categories.ordered.includes(:budget_entries, :documents)
    @envelopes = Current.household.savings_envelopes.ordered
    @projects = Current.household.shared_projects.ordered
    @summary = Budget::Summary.call(household: Current.household, period: @period)
    @expense_chart_data = expense_chart_data(@categories)
    @category = Current.household.budget_categories.new
    @envelope = Current.household.savings_envelopes.new
  end

  private
    # Reuses @categories' eager-loaded budget_entries rather than re-querying —
    # summed and period-scaled the same way Budget::Summary totals the header cards.
    def expense_chart_data(categories)
      categories.select { |category| category.kind == "expense" }
        .map { |category| [ "#{category.emoji} #{category.name}".strip, Budget::Summary.scale(category.budget_entries.sum(&:monthly_amount), @period).to_f ] }
        .select { |_, amount| amount.positive? }
        .sort_by { |_, amount| -amount }
    end
end
