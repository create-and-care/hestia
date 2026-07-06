class LocalesController < ApplicationController
  allow_without_household

  def update
    locale = params[:locale].to_s
    if I18n.available_locales.map(&:to_s).include?(locale)
      Current.user.update!(locale: locale)
    end

    redirect_back fallback_location: root_path
  end
end
