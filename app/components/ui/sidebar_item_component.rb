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

    def initialize(icon:, label:, href: nil, active: false, mod: nil, collapsed: false)
      @icon = icon
      @label = label
      @href = href
      @active = active
      @mod = mod
      @collapsed = collapsed
    end
  end
end
