// Some trigger targets are plain wrapper elements around arbitrary slot
// content (e.g. dropdown-menu/popover triggers carry aria-haspopup on a
// <div>, with the real interactive element rendered inside via a slot) and
// are not themselves focusable, so calling .focus() on them silently does
// nothing. Restore focus to the element itself when it's already focusable,
// otherwise to the first focusable descendant.
export function focusTrigger(el) {
  const focusable = el.matches("button, a[href], input, select, textarea, [tabindex]")
    ? el
    : el.querySelector("button, a[href], input, select, textarea, [tabindex]")
  focusable?.focus()
}
