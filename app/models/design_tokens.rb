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
