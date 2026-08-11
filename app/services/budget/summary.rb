module Budget
  # Aggregates the household's income / expenses / savings and computes the
  # disposable income and the savings rate, in monthly or annual view.
  class Summary
    def self.call(household:, period: :monthly)
      new(household, period).call
    end

    def self.scale(monthly, period)
      period == :annual ? monthly * 12 : monthly
    end

    def initialize(household, period)
      @household = household
      @period = period
    end

    def call
      income  = total_for("income")
      expense = total_for("expense")
      savings = total_for("savings") + envelopes_total
      remaining = income - expense - savings

      {
        income: income, expense: expense, savings: savings, remaining: remaining,
        savings_rate: income.positive? ? (savings / income * 100).round : 0
      }
    end

    private
      def total_for(kind)
        BudgetEntry.joins(:budget_category)
          .where(budget_categories: { household_id: @household.id, kind: kind })
          .sum { |entry| scale(entry.monthly_amount) }
      end

      def envelopes_total
        @household.savings_envelopes.sum { |envelope| scale(envelope.recurring_deposit || 0) }
      end

      def scale(monthly)
        self.class.scale(monthly, @period)
      end
  end
end
