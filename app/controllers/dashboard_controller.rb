class DashboardController < ApplicationController
  # Household dashboard (Spec §7). In Phase 1, it presents the active household,
  # its members, and the invite code; it will be enriched with modules over successive waves.
  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user)
    @other_households = Current.user.households.where.not(id: @household.id)
  end
end
