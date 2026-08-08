# Reads app/assets/stylesheets/application.tailwind.css directly so the
# /design-system/colors page can never drift from the actual tokens — no
# hex values are duplicated here. Swatches are rendered with the real
# Tailwind utility classes (bg-gray-500, bg-success…) so toggling the
# theme (Ui::ThemeToggleComponent) shows their real dark-mode values too.
module DesignTokens
  CSS_PATH = Rails.root.join("app/assets/stylesheets/application.tailwind.css")

  HUE_ORDER = %w[gray red orange amber yellow green cyan blue indigo violet fuchsia pink].freeze

  BRAND_COLORS = %w[brand accent].freeze

  SEMANTIC_COLORS = %w[success warning destructive info link].freeze

  SURFACE_COLORS = %w[background surface surface-hover container container-hover].freeze

  # Resolves a light-mode token to the hex it ends up at, following one level of
  # `var(--other-token)` indirection (--brand is defined as var(--color-clay-600)).
  #
  # For the handful of places that need a *value* rather than a class: the PWA
  # manifest and the theme-color meta tag are read by the OS, not by the
  # browser's CSS engine, so they cannot say `var(--brand)`. They carried
  # #A85030 and #FBF7F4 copied by hand instead, which meant changing the brand
  # left the installed app's chrome on the old one with nothing to catch it.
  #
  # Light mode specifically: both consumers describe the app's default chrome,
  # and the .dark block is a user preference applied afterwards.
  def self.hex(name)
    value = light_mode_value(name)
    return value if value.nil? || value.start_with?("#")

    referenced = value[/\Avar\(\s*(--[a-z0-9-]+)\s*\)\z/, 1]
    referenced ? light_mode_value(referenced.delete_prefix("--")) : value
  end

  def self.light_mode_value(name)
    root = css[/^:root\s*\{(.*?)^\}/m, 1] || ""
    # Palette entries live in @theme, semantic ones in :root — check the
    # narrower scope first so a semantic token wins over a same-named palette one.
    root[/^\s*--#{Regexp.escape(name)}:\s*([^;]+);/, 1]&.strip ||
      css[/^\s*--#{Regexp.escape(name)}:\s*([^;]+);/, 1]&.strip
  end

  def self.raw_palette
    hues = css.scan(/--color-([a-z]+)-(\d+):/).each_with_object({}) do |(hue, shade), acc|
      (acc[hue] ||= []) << shade.to_i
    end.transform_values(&:sort)

    HUE_ORDER.filter_map { |hue| [ hue, hues[hue] ] if hues[hue] }
  end

  def self.css
    @css ||= CSS_PATH.read
  end
end
