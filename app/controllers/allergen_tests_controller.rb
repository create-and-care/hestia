class AllergenTestsController < ApplicationController
  before_action :set_baby

  def create
    @baby.allergen_tests.create(allergen_params)
    redirect_to @baby
  end

  def destroy
    @baby.allergen_tests.find(params[:id]).destroy
    redirect_to @baby
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
    end

    def allergen_params
      params.require(:allergen_test).permit(:allergen, :tested_on, :severity)
    end
end
