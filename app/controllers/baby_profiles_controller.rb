class BabyProfilesController < ApplicationController
  before_action :set_baby, only: %i[show edit update destroy]

  def index
    @babies = Current.household.baby_profiles.ordered
  end

  def show
    @feeding_session = @baby.feeding_sessions.new
    @food_introduction = @baby.food_introductions.new(introduced_on: Date.current)
    @allergen_test = @baby.allergen_tests.new(tested_on: Date.current)
  end

  def new
    @baby = Current.household.baby_profiles.new
    @service_providers = Current.household.service_providers.order(:name)
  end

  def create
    @baby = Current.household.baby_profiles.new(baby_params)
    if @baby.save
      redirect_to @baby, notice: t(".created")
    else
      @service_providers = Current.household.service_providers.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @service_providers = Current.household.service_providers.order(:name)
  end

  def update
    if @baby.update(baby_params)
      redirect_to @baby, notice: t(".updated")
    else
      @service_providers = Current.household.service_providers.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @baby.destroy
    redirect_to baby_profiles_path, notice: t(".deleted")
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:id])
    end

    def baby_params
      params.require(:baby_profile).permit(:name, :born_on, :service_provider_id)
    end
end
