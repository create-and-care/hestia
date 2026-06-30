class DashboardController < ApplicationController
  # Tableau de bord du foyer (CDC §7). En Phase 1, il présente le foyer actif,
  # ses membres et le code d'invitation ; il s'enrichira des modules au fil des vagues.
  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user)
    @other_households = Current.user.households.where.not(id: @household.id)
  end
end
