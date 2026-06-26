// Minimal positioning + outside-click helpers shared by the popover-style
// Stimulus controllers (popover, dropdown, tooltip, hover-card, select,
// combobox, context-menu, navigation-menu). Not a full Floating UI
// replacement — just enough to keep a panel anchored under/over its trigger
// and flipped when it would overflow the viewport.
export function positionFloating(trigger, panel, { placement = "bottom-start", offset = 6 } = {}) {
  const triggerRect = trigger.getBoundingClientRect()
  const panelRect = panel.getBoundingClientRect()
  const viewportWidth = document.documentElement.clientWidth
  const viewportHeight = document.documentElement.clientHeight

  let top = triggerRect.bottom + offset
  if (placement.startsWith("top") || top + panelRect.height > viewportHeight) {
    top = triggerRect.top - panelRect.height - offset
  }

  let left = placement.endsWith("end") ? triggerRect.right - panelRect.width : triggerRect.left
  if (left + panelRect.width > viewportWidth) left = viewportWidth - panelRect.width - 8
  if (left < 8) left = 8

  panel.style.position = "fixed"
  panel.style.top = `${Math.max(top, 8)}px`
  panel.style.left = `${left}px`
}

export function positionAtPoint(panel, x, y) {
  const panelRect = panel.getBoundingClientRect()
  const viewportWidth = document.documentElement.clientWidth
  const viewportHeight = document.documentElement.clientHeight

  panel.style.position = "fixed"
  panel.style.left = `${Math.min(x, viewportWidth - panelRect.width - 8)}px`
  panel.style.top = `${Math.min(y, viewportHeight - panelRect.height - 8)}px`
}

export function onClickOutside(elements, callback) {
  const list = Array.isArray(elements) ? elements : [ elements ]
  const handler = (event) => {
    if (list.some((el) => el && el.contains(event.target))) return
    callback(event)
  }
  document.addEventListener("click", handler, true)
  return () => document.removeEventListener("click", handler, true)
}
