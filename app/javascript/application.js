// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Registers the service worker that makes the app installable and gives a
// failed navigation somewhere to land (app/views/pwa/service-worker.js).
//
// Scope "/" is only granted because PwaController answers with
// Service-Worker-Allowed: /. Registration is deliberately unawaited and its
// failure swallowed: a browser that refuses — Safari in a private window,
// an origin served over plain HTTP on a LAN, a user who disabled workers —
// must still get the whole app, just without the offline page.
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker", { scope: "/" }).catch(() => {})
  })
}
