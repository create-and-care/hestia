# Be sure to restart your server when you modify this file.
#
# Application-wide Content Security Policy.
# https://guides.rubyonrails.org/security.html#content-security-policy-header
#
# This is the app's primary defence against XSS. It is a stronger one than
# sanitising note/message bodies would be: `sanitize` permits an allow-list of
# tags, whereas the escaping already applied before markup (see notes_helper)
# permits none, and this header then denies any script the app didn't emit
# itself — including one that got past the escaping.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self

    # No third-party JavaScript at all: the bundle is built by esbuild and
    # served from app/assets/builds. Inline scripts are reached by nonce, not
    # by :unsafe_inline — see content_security_policy_nonce_directives below.
    policy.script_src  :self
    policy.object_src  :none

    # :unsafe_inline is load-bearing here and cannot be swapped for a nonce.
    # A nonce authorises <style> *elements*; it does nothing for the inline
    # `style` *attribute*, which is how the components that compute a
    # dimension at render time pass it (chart bar heights, progress widths,
    # aspect ratios, colour swatches on the docs pages). Worse, adding a nonce
    # to style-src makes browsers ignore :unsafe_inline entirely, so those
    # attributes would silently stop applying. Google Fonts is listed because
    # application.tailwind.css opens with an @import to it.
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com"
    policy.font_src    :self, :data, "https://fonts.gstatic.com"

    # Recipe catalog entries carry an image_url crawled from whatever source
    # site the installation configured (RECIPE_CATALOG_SITEMAP_URL), so the
    # host isn't knowable here. Everything else — Active Storage variants,
    # icons, illustrations — is same-origin. :data covers inline SVG data URIs.
    policy.img_src     :self, :data, :https

    # Same-origin only: the three fetch() call sites (barcode lookup, geocode
    # lookup, sortable reorder) all post back to this app, and so do Turbo and
    # the Solid Cable websocket — :self covers ws:/wss: on the same host.
    policy.connect_src :self

    # The document preview frames an Active Storage blob (PDFs); nothing may
    # frame *us*, which is the clickjacking control.
    policy.frame_src :self
    policy.frame_ancestors :self

    # Installable PWA — the manifest and the service worker are both served by
    # the app itself (app/views/pwa/*). Without these two, default_src would
    # cover them, but naming them keeps the PWA from breaking silently if
    # default_src is ever tightened.
    policy.worker_src   :self
    policy.manifest_src :self

    # Nothing in the app submits a form off-site, and <base> is never used.
    policy.form_action :self
    policy.base_uri    :self

    # Deliberately no upgrade-insecure-requests: the declared audience is the
    # AGPL self-hoster, and a plain-HTTP LAN install is a supported setup —
    # same reasoning as the FORCE_SSL switch in config/environments/production.rb.
  end

  # A fresh nonce per response rather than Rails' suggested `session.id`: a
  # first-time visitor has no session id yet, which would emit nonce="" and
  # get the anti-FOUC script below blocked — bringing back the exact
  # light-mode flash that script exists to prevent.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

  # script-src only, on purpose. Adding style-src here would void the
  # :unsafe_inline it needs (see above).
  config.content_security_policy_nonce_directives = %w[script-src]
end
