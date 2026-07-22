# Production error tracking. Wire-compatible with both hosted
# Sentry and self-hostable GlitchTip — set SENTRY_DSN (or
# `bin/rails credentials:edit` -> sentry: dsn:) to the target's DSN. Left
# unconfigured, Sentry.init no-ops: nothing is sent anywhere.
dsn = ENV["SENTRY_DSN"].presence || Rails.application.credentials.dig(:sentry, :dsn)

Sentry.init do |config|
  config.dsn = dsn
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.enabled_environments = %w[production]
  config.traces_sample_rate = 0.1
end
