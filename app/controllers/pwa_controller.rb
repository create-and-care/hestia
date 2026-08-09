# Serves the two files under app/views/pwa: the web app manifest and the
# service worker.
#
# Rails ships Rails::PwaController for exactly this, and the generated routes
# pointed at it — but it cannot set Service-Worker-Allowed, and without that
# header a worker served from /service-worker is only permitted to control
# /service-worker/*. It would register successfully and be in charge of
# nothing, which is the most expensive kind of working.
#
# Both actions are reachable signed out on purpose: the browser fetches the
# manifest while deciding whether the app is installable, and re-fetches the
# worker on its own schedule, in neither case carrying a session.
class PwaController < ApplicationController
  allow_unauthenticated_access

  # Deliberately not `skip_forgery_protection` (CodeQL rb/csrf-protection-disabled).
  # Both routes are GET, and verify_authenticity_token passes every GET
  # unconditionally, so skipping it never protected anything here — it only
  # left the controller reading as one with CSRF protection switched off, and
  # would have silently carried that over to any non-GET action added later.
  #
  # What the worker genuinely needs lifted is the *other* half of forgery
  # protection: an after_action that refuses to serve a JavaScript body to a
  # plain, non-XHR GET, so that a third party's <script src> cannot read a
  # response built from the visitor's session. service-worker.js is a static
  # file with nothing of the visitor in it, and the browser fetches it in
  # exactly the shape that check rejects. The manifest is left alone —
  # application/manifest+json is not JavaScript, so the check never fires on it.
  skip_after_action :verify_same_origin_request, only: :service_worker

  # `formats:` is not decoration on either of these: the browser asks for both
  # with an Accept header of its own choosing, and without it Rails looks for
  # an .html template and finds neither manifest.json.erb nor service-worker.js.
  def manifest
    render template: "pwa/manifest", formats: [ :json ], layout: false, content_type: "application/manifest+json"
  end

  def service_worker
    response.headers["Service-Worker-Allowed"] = "/"
    render template: "pwa/service-worker", formats: [ :js ], layout: false, content_type: "text/javascript"
  end
end
