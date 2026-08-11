module Budget
  # Builds the [label, amount] pairs behind the expense breakdown chart on the
  # Budget page: expense categories only, period-scaled and summed the same
  # way Budget::Summary totals the header cards, positive amounts only,
  # largest first.
  class ExpenseChartData
    def self.call(categories:, period: :monthly)
      new(categories, period).call
    end

    def initialize(categories, period)
      @categories = categories
      @period = period
    end

    def call
      @categories.select { |category| category.kind == "expense" }
        .map { |category| [ "#{category.emoji} #{category.name}".strip, Summary.scale(category.budget_entries.sum(&:monthly_amount), @period).to_f ] }
        .select { |_, amount| amount.positive? }
        .sort_by { |_, amount| -amount }
    end
  end
end
