class HouseholdsController < ApplicationController
  allow_without_household only: %i[new create]

  TABS = %w[general members notifications api sessions modules roadmap].freeze

  def new
    @household = Household.new
  end

  def create
    @household = Household.new(household_params)

    if @household.valid?
      ActiveRecord::Base.transaction do
        @household.save!
        @household.memberships.create!(user: Current.user, role: :admin)
        @household.shopping_lists.create!(name: t("shopping_lists.default_list_name"))
      end
      switch_household(@household)
      redirect_to root_path, notice: t(".created", name: @household.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user).order(:role)
    @other_households = Current.user.households.where.not(id: @household.id)
    @notification_preference = NotificationPreference.for_user(Current.user)
    @api_tokens = Current.user.api_tokens.order(created_at: :desc)
    @api_token = ApiToken.new
    @sessions = Current.user.sessions.order(created_at: :desc)
    @milestones = Roadmap.milestones
    @default_tab = TABS.include?(params[:tab]) ? params[:tab] : "general"
  end

  # Used in particular to enable/change the public holiday reference
  # and the household's time zone (day-boundary calculations).
  def update
    if Current.household.update(household_update_params)
      redirect_back fallback_location: household_path(Current.household), notice: t(".updated")
    else
      redirect_back fallback_location: household_path(Current.household), alert: t(".failed")
    end
  end

  # Enables/disables sidebar modules for the household (admins only, Household#module_enabled?),
  # plus the finer-grained Pool switch (Household#pool_enabled?) shown on the same tab.
  def update_modules
    unless current_membership&.admin?
      return redirect_to household_path(Current.household, tab: "modules"), alert: t(".not_authorized")
    end

    enabled_modules = Array(params.dig(:household, :enabled_modules))
    disabled_modules = Household::MODULE_KEYS - enabled_modules
    # The settings form always submits a hidden "0" fallback alongside the
    # switch (like required_meal_types above), so the key is present whenever
    # a real submission happens; a caller that omits it entirely (e.g. an
    # older client) leaves the current value untouched rather than nulling
    # out this NOT NULL column.
    pool_enabled = if params[:household]&.key?(:pool_enabled)
      ActiveModel::Type::Boolean.new.cast(params.dig(:household, :pool_enabled))
    else
      Current.household.pool_enabled
    end

    if Current.household.update(disabled_modules: disabled_modules, pool_enabled: pool_enabled)
      redirect_to household_path(Current.household, tab: "modules"), notice: t("households.update.updated")
    else
      redirect_to household_path(Current.household, tab: "modules"), alert: t("households.update.failed")
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

  def regenerate_invite_code
    unless current_membership&.admin?
      return redirect_to household_path(Current.household), alert: t(".not_authorized")
    end

    Current.household.regenerate_invite_code!
    redirect_to household_path(Current.household), notice: t(".regenerated")
  end

  # A household created by mistake shouldn't stay permanent (admin only).
  # Every session with this household set as active — this user's and every
  # other member's — must be cleared first: `sessions.active_household_id`
  # has no ON DELETE clause, so destroying the household would otherwise hit
  # a foreign key violation for anyone still "on" it.
  def destroy
    household = Current.household
    unless current_membership&.admin?
      return redirect_to household_path(household), alert: t(".not_authorized")
    end

    Session.where(active_household: household).update_all(active_household_id: nil)
    household.destroy!

    next_household = Current.user.households.reload.first
    if next_household
      switch_household(next_household)
      redirect_to root_path, notice: t(".deleted")
    else
      Current.household = nil
      redirect_to onboarding_path, notice: t(".deleted")
    end
  end

  private
    def household_params
      params.require(:household).permit(:name)
    end

    def household_update_params
      params.require(:household).permit(:holiday_country, :time_zone, :default_view, required_meal_types: [])
    end
end
