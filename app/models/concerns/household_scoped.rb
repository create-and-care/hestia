# Household scoping pattern reused by the Phase 2 models.
# Filtering is always done via the authenticated user's household
# (Current.household), never via a parameter supplied by the client (cf. Spec §15).
module HouseholdScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :household
    scope :for_household, ->(household) { where(household: household) }
  end
end
