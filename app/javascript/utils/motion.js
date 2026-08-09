// Motion durations, in milliseconds, for the JS half of the design system.
//
// The CSS half already has its own: `--tw-duration` and the `duration-*`
// utilities in application.tailwind.css. But a panel's exit is driven from
// JavaScript — the element has to stay in the DOM until the animation ends —
// so both halves have to agree on how long that is, and they had no way to.
// Three controllers had each picked a number: 200, 100, 4000.
//
// PANEL matches the 150ms default in the animate-in/animate-out utilities plus
// a little slack, which is what transition.js was already assuming.
export const DURATION = {
  // A panel unmounting: dropdowns, popovers, comboboxes, selects.
  PANEL: 200,
  // A tooltip, which is deliberately quicker — it follows the pointer and a
  // panel-length exit reads as lag.
  TOOLTIP: 100,
  // How long a tooltip waits before it gives up and hides, so crossing a gap
  // between trigger and panel does not dismiss it.
  TOOLTIP_GRACE: 80,
  // How long a toast stays up before dismissing itself.
  TOAST: 4000
}
