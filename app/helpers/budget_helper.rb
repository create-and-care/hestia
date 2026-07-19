module BudgetHelper
  def budget_kind_label(kind) = t("budget.kinds.#{kind}", default: kind)
  def budget_kind_options = BudgetCategory::KINDS.map { |kind| [ budget_kind_label(kind), kind ] }

  def money(amount)
    number_to_currency(amount, unit: "€", format: "%n %u", precision: 0, delimiter: " ")
  end

  # Budget-health gauge variant based on the savings rate / disposable income,
  # using the design system's semantic (dark-mode-aware) badge variants
  # instead of hardcoded pastel Tailwind colors.
  def health_variant(summary)
    if summary[:remaining].negative? then :destructive
    elsif summary[:savings_rate] >= 10 then :success
    else :warning
    end
  end
end
