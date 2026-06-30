module HouseholdScoping
  extend ActiveSupport::Concern

  included do
    before_action :set_current_household
    before_action :require_household
    helper_method :current_household
  end

  class_methods do
    def allow_without_household(**options)
      skip_before_action :require_household, **options
    end
  end

  private
    def current_household
      Current.household
    end

    def set_current_household
      return unless Current.user

      Current.household = Current.session.active_household || Current.user.households.first
    end

    def require_household
      redirect_to onboarding_path if Current.user && Current.household.nil?
    end

    def switch_household(household)
      Current.session.update!(active_household: household)
      Current.household = household
    end
end
