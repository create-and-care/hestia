class ApplicationController < ActionController::Base
  include Authentication
  include HouseholdScoping
  include ModuleGating
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale
  around_action :switch_time_zone

  private
    # English is the app-wide default; a signed-in user can switch to French
    # (User#locale). Wrapped in an around_action so I18n.locale never leaks
    # into another request once this one finishes (Rails reuses threads).
    def switch_locale(&action)
      I18n.with_locale(Current.user&.locale || I18n.default_locale, &action)
    end

    # "Today"-sensitive calculations (Fridge expiry, Task due dates, the daily
    # digest) must resolve against the household's time zone, not the server's
    # (config.time_zone "UTC"). Wrapped in an around_action for the same
    # thread-reuse reason as switch_locale above.
    def switch_time_zone(&action)
      Time.use_zone(Current.household&.time_zone || "UTC", &action)
    end
end
