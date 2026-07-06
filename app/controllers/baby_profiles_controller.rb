class BabyProfilesController < ApplicationController
  before_action :set_baby, only: %i[show edit update destroy]

  def index
    @babies = Current.household.baby_profiles.ordered
  end

  def show
    @feeding_session = @baby.feeding_sessions.new(started_at: Time.current)
    @food_introduction = @baby.food_introductions.new(introduced_on: Date.current)
    @allergen_test = @baby.allergen_tests.new(tested_on: Date.current)
  end

  def new
    @baby = Current.household.baby_profiles.new
  end

  def create
    @baby = Current.household.baby_profiles.new(baby_params)
    if @baby.save
      redirect_to @baby, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @baby.update(baby_params)
      redirect_to @baby, notice: t(".updated")
    else
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
      params.require(:baby_profile).permit(:name, :born_on)
    end
end
