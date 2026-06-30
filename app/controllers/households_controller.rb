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
      redirect_to root_path, notice: "Foyer « #{@household.name} » créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @household = Current.household
  end

  # Bascule du foyer actif (multi-foyer).
  def activate
    membership = Current.user.memberships.find_by(household_id: params[:id])

    if membership
      switch_household(membership.household)
      redirect_to root_path, notice: "Foyer actif : « #{membership.household.name} »."
    else
      redirect_to root_path, alert: "Foyer introuvable."
    end
  end

  private
    def household_params
      params.require(:household).permit(:name)
    end
end
