class DashboardController < ApplicationController
  # Household dashboard (Spec §7). In Phase 1, it presents the active household,
  # its members, and the invite code; it will be enriched with modules over successive waves.
  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user)
    @other_households = Current.user.households.where.not(id: @household.id)
    # Vehicles/Dashboard interconnection: surfaces the module's central business rule (upcoming
    # technical inspection deadlines) somewhere other than each vehicle's own page.
    @vehicles_needing_attention = @household.vehicles.select { |vehicle| vehicle.inspection_status.in?(%i[urgent expired]) }
  end
end
