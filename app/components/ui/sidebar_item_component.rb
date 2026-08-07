module Ui
  # A sidebar navigation row — owns both the expanded and collapsed (icon-rail)
  # recipes, so the 64px rail fallback in _app_sidebar.html.erb doesn't need to
  # be reimplemented by hand. The collapsed look is driven by the ancestor
  # sidebar's `data-collapsed` attribute via `group-data-[collapsed=true]:`
  # utilities (see sidebar_controller.js), so a single server render adapts
  # live as the user toggles the rail — no re-render needed.
  #
  # `collapsed:` does not drive that live behavior; it forces the collapsed
  # recipe statically, for previews and tests rendered outside a live sidebar.
  class SidebarItemComponent < ApplicationComponent
    renders_one :trailing

    # `preload:` stamps data-turbo-preload, which makes Turbo fetch the target
    # into its snapshot cache once the page has loaded, so the next visit is
    # instant. Deliberately opt-in per row rather than on by default: that cache
    # holds ten snapshots, so preloading the whole ~25-row module nav would
    # evict its own entries and spend a background request per row to do it.
    # Everything else is already covered by Turbo 8's hover prefetch, which is
    # on by default and costs nothing until the pointer actually lands.
    def initialize(icon:, label:, href: nil, active: false, mod: nil, collapsed: false, preload: false)
      @icon = icon
      @label = label
      @href = href
      @active = active
      @mod = mod
      @collapsed = collapsed
      @preload = preload
    end
  end
end
