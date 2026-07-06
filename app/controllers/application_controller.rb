class ApplicationController < ActionController::Base
  include Authentication
  include HouseholdScoping
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  private
    # English is the app-wide default; a signed-in user can switch to French
    # (User#locale). Wrapped in an around_action so I18n.locale never leaks
    # into another request once this one finishes (Rails reuses threads).
    def switch_locale(&action)
      I18n.with_locale(Current.user&.locale || I18n.default_locale, &action)
    end
end
