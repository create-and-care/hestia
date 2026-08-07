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
  # Read it as a diagnostic, not as a gate. It currently reports 57 failures,
  # and every one of them is a test asserting English interface copy —
  # `assert_select ... "Name can't be blank"`, `aria-label="Edit ..."`, flash
  # messages. Not one is a date. Making it green means rewriting those
  # assertions to be locale-independent, which is a real piece of work and not
  # I18N-03's; what I18N-03 owns is pinned directly instead, by
  # test/lib/localized_dates_test.rb and
  # test/integration/localized_dates_rendering_test.rb, both of which run in
  # both locales on every ordinary `bin/rails test`.
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
  # the tool rather than reading eleven controllers by hand — and it is how the
  # next batch should be found too, so the switch stays.
  #
  # It is not on by default because Bullet judges a *rendered request*: a
  # controller can be perfectly eager-loaded and still trip it from a partial
  # reached only by some fixtures, and a red build on that would push people to
  # safelist rather than to look.
  #
  # What it still reports after PERF-06, each looked at and left alone:
  #   * "USE eager loading" on Task => :task_reminders, PlantCareTask =>
  #     :plant_care_completions — both raised by #destroy, where the
  #     `dependent: :destroy` cascade has to load the children to run their
  #     callbacks. No `includes` applies; only `delete_all` would, and that
  #     would skip the callbacks on purpose.
  #   * "USE eager loading" on LoyaltyCard => :address — raised by reordering,
  #     where each card's `address_belongs_to_household` validation reads the
  #     association on save. A view concern it is not.
  #   * "AVOID eager loading" on WorkoutTemplate => :workout_template_exercises
  #     — the index renders `.size`, which Bullet does not count as a read.
  #     The preload is what keeps that `.size` from being a COUNT per row.
  #   * "AVOID eager loading" on Task => :task_category, Document =>
  #     :file_attachment, GiftList => :contact, CalendarEvent => :participants
  #     — pre-existing, and each needs its own look at whether the association
  #     is genuinely unused or merely unused by the fixtures at hand.
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = ENV["BULLET_RAISE"].present?
    # Preloading a has_many :through (participants) always preloads its join
    # association (event_participants) too — app code only ever calls
    # .participants, so Bullet permanently flags the join side as "unused".
    # That's a structural false positive, not a real N+1 risk, so it's safelisted.
    Bullet.add_safelist type: :unused_eager_loading, class_name: "CalendarEvent", association: :event_participants
  end
end
