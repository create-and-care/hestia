# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Rate limiting counts through the *controller* cache store, which defaults to
  # Rails.cache — the null store above. A null store's #increment always returns
  # nil, so every `rate_limit` in the app would be silently inert here and could
  # never be asserted. Pointing only this one at a real store fixes that while
  # leaving Rails.cache null, so tests that exercise application caching still
  # have to opt in explicitly (see ActiveSupport::Testing::CacheStore).
  config.action_controller.cache_store = :memory_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # `LOCALE=fr bin/rails test` runs the whole suite through French — the
  # fallback locale here, and the fixture users' own locale in
  # test/fixtures/users.yml, since every signed-in page renders in theirs.
  #
  # It is green, and that is the point: it started at 93 failures, none of
  # which were bugs. Every one was an assertion spelling an English string —
  # "Name can't be blank", aria-label="Edit …", a flash message, a date, a
  # currency — which is a test asserting, silently, that the suite runs in
  # English. They now resolve the same string through I18n, so the suite
  # checks behaviour in either language instead of checking the language.
  #
  # Worth running before touching anything user-facing. A new hard-coded
  # string will pass in English and fail here, which is exactly when it is
  # cheapest to notice.
  config.i18n.default_locale = ENV.fetch("LOCALE", "en").to_sym

  # Active Record Encryption (ExternalCalendarConnection#access_token/refresh_token,
  # needs 3 keys. Throwaway, committed values are fine here since
  # the test database is disposable — production reads real keys from credentials
  # (`bin/rails db:encryption:init` then `bin/rails credentials:edit`, see README),
  # never from this file.
  config.active_record.encryption.primary_key = "test" * 8
  config.active_record.encryption.deterministic_key = "test" * 8
  config.active_record.encryption.key_derivation_salt = "test" * 8

  # Detects N+1 queries and unused eager loading (reliability).
  #
  # Logs by default; `BULLET_RAISE=1 bin/rails test` turns every detection into
  # a failure. That is how PERF-06 enumerated the missing `includes` — asking
  # the tool rather than reading eleven controllers by hand — and how the four
  # that survived it were then closed:
  #
  #   * Task => :task_reminders and PlantCareTask => :plant_care_completions
  #     were `dependent: :destroy` cascades loading every child row to run
  #     callbacks that do not exist. Both are `delete_all` now.
  #   * LoyaltyCard => :address was a validation re-reading the association on
  #     every save, so a drag-and-drop reorder issued one query per card. It
  #     now runs only when the foreign key actually changed.
  #   * Document => :file_attachment and Task => :task_category were preloads
  #     of associations no view reads — the document lists show a name and a
  #     lazily-loaded preview frame, and the kanban groups on task_category_id.
  #     Both are gone.
  #
  # It is still not on by default, because Bullet judges a *rendered request*:
  # a controller can be perfectly eager-loaded and still trip it from a partial
  # only some fixtures reach, and a red build on that teaches people to
  # safelist rather than to look. The safelists below are what that looks like
  # when it is the right answer — each names why the association is real.
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = ENV["BULLET_RAISE"].present?

    # Preloading a has_many :through (participants) always preloads its join
    # association (event_participants) too — app code only ever calls
    # .participants, so Bullet permanently flags the join side as "unused".
    # That's a structural false positive, not a real N+1 risk.
    Bullet.add_safelist type: :unused_eager_loading, class_name: "CalendarEvent", association: :event_participants

    # Read by the view, but only on a row the fixtures do not provide: no
    # calendar event has participants and no gift list has a contact, so the
    # branch that reads them never runs here. Removing the preload would be a
    # real N+1 the moment a household used the feature.
    Bullet.add_safelist type: :unused_eager_loading, class_name: "CalendarEvent", association: :participants
    Bullet.add_safelist type: :unused_eager_loading, class_name: "GiftList", association: :contact

    # `.size` on a preloaded association is what stops it being a COUNT per
    # row, but Bullet does not count it as a read.
    Bullet.add_safelist type: :unused_eager_loading, class_name: "WorkoutTemplate", association: :workout_template_exercises
  end
end
