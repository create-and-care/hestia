class HouseholdsController < ApplicationController
  allow_without_household only: %i[new create]

  def new
    @household = Household.new
  end

  def create
    @household = Household.new(household_params)

    if @household.valid?
      ActiveRecord::Base.transaction do
        @household.save!
        @household.memberships.create!(user: Current.user, role: :admin)
      end
      switch_household(@household)
      redirect_to root_path, notice: t(".created", name: @household.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @household = Current.household
    @notification_preference = NotificationPreference.for_user(Current.user)
    @api_tokens = Current.user.api_tokens.order(created_at: :desc)
    @api_token = ApiToken.new
  end

  # Used in particular to enable/change the public holiday reference (Spec §9.2)
  # and the household's time zone (Spec §9.2, §9.3 — day-boundary calculations).
  def update
    if Current.household.update(household_update_params)
      redirect_back fallback_location: household_path(Current.household), notice: t(".updated")
    else
      redirect_back fallback_location: household_path(Current.household), alert: t(".failed")
    end
  end

  # Enables/disables sidebar modules for the household (admins only, Household#module_enabled?).
  def update_modules
    unless current_membership&.admin?
      return redirect_to household_path(Current.household), alert: t(".not_authorized")
    end

    enabled_modules = Array(params.dig(:household, :enabled_modules))
    disabled_modules = Household::MODULE_KEYS - enabled_modules

    if Current.household.update(disabled_modules: disabled_modules)
      redirect_to household_path(Current.household), notice: t("households.update.updated")
    else
      redirect_to household_path(Current.household), alert: t("households.update.failed")
    end
  end

  # Switches the active household (multi-household).
  def activate
    membership = Current.user.memberships.find_by(household_id: params[:id])

    if membership
      switch_household(membership.household)
      redirect_to root_path, notice: t(".switched", name: membership.household.name)
    else
      redirect_to root_path, alert: t(".not_found")
    end
  end

  private
    def household_params
      params.require(:household).permit(:name)
    end

    def household_update_params
      params.require(:household).permit(:holiday_country, :time_zone)
    end
end
