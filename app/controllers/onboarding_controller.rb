class OnboardingController < ApplicationController
  allow_without_household

  # Choix après l'inscription : créer un foyer ou en rejoindre un via code.
  def show
    redirect_to root_path if Current.household.present?
  end
end
