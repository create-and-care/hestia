module Budget
  # Agrège revenus / charges / épargne du foyer et calcule le reste à vivre et le
  # taux d'épargne, en vue mensuelle ou annuelle (CDC §11.4).
  class Summary
    def self.call(household:, period: :monthly)
      new(household, period).call
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
        @period == :annual ? monthly * 12 : monthly
      end
  end
end
