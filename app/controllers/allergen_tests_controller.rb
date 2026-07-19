class AllergenTestsController < ApplicationController
  before_action :set_baby
  before_action :set_allergen_test, only: %i[edit update destroy]

  def create
    test = @baby.allergen_tests.new(allergen_params)
    if test.save
      redirect_to @baby, notice: t(".created")
    else
      redirect_to @baby, alert: test.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @allergen_test.update(allergen_params)
      redirect_to @baby, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @allergen_test.destroy
    redirect_to @baby, notice: t(".deleted")
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
    end

    def set_allergen_test
      @allergen_test = @baby.allergen_tests.find(params[:id])
    end

    def allergen_params
      params.require(:allergen_test).permit(:allergen, :tested_on, :severity)
    end
end
