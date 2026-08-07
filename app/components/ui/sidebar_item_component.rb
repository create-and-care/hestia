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
    # Three leading treatments, one per depth in the nav hierarchy. They are not
    # interchangeable styles — each answers "how much weight does a row at this
    # level deserve":
    #   :default  module medallion (tinted circle). Top-level destinations that
    #             stand alone, and every call site outside the app sidebar.
    #   :plain    bare 16px glyph. Rows inside a card where a column of tinted
    #             circles would out-shout the labels — the secondary menu card.
    #   :sub      no glyph at all. Children of a collapsible group, where the
    #             group's own icon plus the indent rule already carry the
    #             hierarchy and a second icon column only adds noise.
    VARIANTS = { default: "h-11", plain: "h-10", sub: "h-9" }.freeze

    renders_one :trailing

    # `preload:` stamps data-turbo-preload, which makes Turbo fetch the target
    # into its snapshot cache once the page has loaded, so the next visit is
    # instant. Deliberately opt-in per row rather than on by default: that cache
    # holds ten snapshots, so preloading the whole ~25-row module nav would
    # evict its own entries and spend a background request per row to do it.
    # Everything else is already covered by Turbo 8's hover prefetch, which is
    # on by default and costs nothing until the pointer actually lands.
    def initialize(icon: nil, label:, href: nil, active: false, mod: nil, collapsed: false, preload: false, variant: :default)
      @icon = icon
      @label = label
      @href = href
      @active = active
      @mod = mod
      @collapsed = collapsed
      @preload = preload
      @variant = variant
    end

    private

      # :sub rows have nothing to show in the 64px rail, which is why the rail
      # hides whole group panels rather than trying to render their children
      # (see shared/_sidebar_nav.html.erb).
      def leading
        case @variant
        when :default
          render Ui::ModuleMedallionComponent.new(mod: @mod, icon: @icon, size: :sm)
        when :plain
          tag.span(lucide_icon(@icon, css_class: "size-4"), class: "shrink-0 text-secondary")
        end
      end
  end
end
