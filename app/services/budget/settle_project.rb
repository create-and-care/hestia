module Budget
  # Computes, for a shared expenses project, each participant's balance
  # (positive = should be reimbursed, negative = owes money), by splitting the
  # total equally.
  class SettleProject
    Balance = Struct.new(:participant, :amount)
    Transfer = Struct.new(:from, :to, :amount)

    def self.call(project:)
      participants = project.shared_project_participants.to_a
      return [] if participants.empty?

      total = project.shared_expenses.sum(:amount)
      share = total / participants.size

      paid = Hash.new(0)
      project.shared_expenses.each do |expense|
        paid[expense.shared_project_participant_id] += expense.amount if expense.shared_project_participant_id
      end

      participants.map { |participant| Balance.new(participant, (paid[participant.id] - share).round(2)) }
    end

    # A minimal set of payments that settles every balance ("who
    # pays whom"), beyond the plain net-balance-per-participant view: greedily
    # matches the largest debtor against the largest creditor each round,
    # which yields at most participants.size - 1 transfers.
    def self.transfers(project:)
      balances = call(project: project).map(&:dup)
      transfers = []

      loop do
        debtor = balances.select { |balance| balance.amount.negative? }.min_by(&:amount)
        creditor = balances.select { |balance| balance.amount.positive? }.max_by(&:amount)
        break if debtor.nil? || creditor.nil?

        amount = [ -debtor.amount, creditor.amount ].min.round(2)
        transfers << Transfer.new(debtor.participant, creditor.participant, amount)
        debtor.amount = (debtor.amount + amount).round(2)
        creditor.amount = (creditor.amount - amount).round(2)
      end

      transfers
    end
  end
end
