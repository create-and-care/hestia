class OnboardingController < ApplicationController
  allow_without_household

  # Choice after sign-up: create a household or join one via a code.
  def show
    redirect_to root_path if Current.household.present?
  end
end
