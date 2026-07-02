module Budget
  # Calcule, pour un projet de dépenses partagées, le solde de chaque participant
  # (positif = doit être remboursé, négatif = doit de l'argent), en répartissant le
  # total à parts égales (CDC §11.4).
  class SettleProject
    Balance = Struct.new(:participant, :amount)

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
  end
end
