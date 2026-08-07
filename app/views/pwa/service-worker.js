// Hestia's service worker. Registered from app/javascript/application.js with
// scope "/", which only works because PwaController sends
// Service-Worker-Allowed: / — a worker served from /service-worker would
// otherwise be allowed to control /service-worker/* and nothing else, i.e. be
// registered and in charge of nothing.
//
// Deliberately *not* a cache-everything worker. This app's pages are all
// household data that changes under the user's hands; serving a stale
// dashboard from a cache would be worse than saying nothing. The only thing
// cached is the offline page itself, so that a navigation attempted with no
// network lands somewhere that explains itself instead of on the browser's
// dinosaur.

const VERSION = "v1";
const OFFLINE_CACHE = `hestia-offline-${VERSION}`;
const OFFLINE_URL = "/offline.html";

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(OFFLINE_CACHE)
      .then((cache) => cache.add(new Request(OFFLINE_URL, { cache: "reload" })))
      .then(() => self.skipWaiting())
  );
});

// A version bump renames the cache; everything under the old name goes.
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== OFFLINE_CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

// Only navigations are intercepted, and only to catch their failure. Assets,
// Turbo Stream requests and form posts go straight to the network: a
// half-cached asset set is how a Rails app ends up serving last week's
// JavaScript against this week's HTML.
self.addEventListener("fetch", (event) => {
  if (event.request.mode !== "navigate") return;

  event.respondWith(
    fetch(event.request).catch(() => caches.match(OFFLINE_URL, { cacheName: OFFLINE_CACHE }))
  );
});

// Web Push, once subscriptions exist server-side (Notification already models
// everything a push payload would carry).
//
// self.addEventListener("push", async (event) => {
//   const { title, options } = await event.data.json()
//   event.waitUntil(self.registration.showNotification(title, options))
// })
