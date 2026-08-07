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
  skip_forgery_protection

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
