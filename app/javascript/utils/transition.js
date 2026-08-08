import { DURATION } from "./motion"

// Drives the [data-state="open"|"closed"] lifecycle that the animate-in/out
// CSS utilities (application.tailwind.css) key off of — the Stimulus-side
// equivalent of Radix's data-state, since we have no primitive managing it
// for us. Each panel needs `hidden` + `data-state="closed"` initially.
export function openPanel(panel) {
  clearTimeout(panel._hideTimer)
  cancelAnimationFrame(panel._openFrame)
  panel.hidden = false
  // rAF so the browser registers the element as visible before the
  // [data-state="open"] selector starts matching — otherwise the enter
  // animation can be skipped on the same frame as un-hiding.
  panel._openFrame = requestAnimationFrame(() => { panel.dataset.state = "open" })
}

export function closePanel(panel, { duration = DURATION.PANEL } = {}) {
  cancelAnimationFrame(panel._openFrame)
  panel.dataset.state = "closed"
  clearTimeout(panel._hideTimer)
  panel._hideTimer = setTimeout(() => { panel.hidden = true }, duration)
}

// For accordion/collapsible: sets --content-height from the panel's actual
// height so the accordion-down/up keyframes can animate to/from it.
export function measureContentHeight(panel) {
  panel.style.setProperty("--content-height", `${panel.scrollHeight}px`)
}
