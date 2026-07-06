module BudgetHelper
  KIND_LABELS = { "income" => "Revenus", "expense" => "Charges", "savings" => "Épargne" }.freeze

  def budget_kind_label(kind) = KIND_LABELS.fetch(kind, kind)
  def budget_kind_options = BudgetCategory::KINDS.map { |kind| [ budget_kind_label(kind), kind ] }

  def money(amount)
    number_to_currency(amount, unit: "€", format: "%n %u", precision: 0, delimiter: " ")
  end

  # Budget-health gauge color based on the savings rate / disposable income.
  def health_class(summary)
    if summary[:remaining].negative? then "bg-red-100 text-red-700"
    elsif summary[:savings_rate] >= 10 then "bg-green-100 text-green-700"
    else "bg-yellow-100 text-yellow-800"
    end
  end
end
