require "test_helper"

# Guards the "descendant <a> inherits its container's color" design-system rule
# (see .on-tone in application.tailwind.css) — the selected filter/folder chip
# renders a bare <a> directly on a solid --brand fill, and after inheriting the
# badge's own foreground it must still clear WCAG AA rather than just swapping
# one illegible color for another.
class BadgeLinkContrastTest < ActiveSupport::TestCase
  MIN_CONTRAST = 4.5
  CSS_PATH = Rails.root.join("app/assets/stylesheets/application.tailwind.css")

  test "selected badge text clears 4.5:1 against its fill in light mode" do
    assert_contrast(:root, "--button-bg-primary", "--text-inverse")
  end

  test "selected badge text clears 4.5:1 against its fill in dark mode" do
    assert_contrast(:dark, "--button-bg-primary", "--text-inverse")
  end

  private

    def assert_contrast(scope, bg_name, fg_name)
      bg = resolve(scope, bg_name)
      fg = resolve(scope, fg_name)
      ratio = contrast_ratio(bg, fg)

      assert_operator ratio, :>=, MIN_CONTRAST,
        "#{fg_name} (#{fg}) on #{bg_name} (#{bg}) in #{scope} is only #{ratio.round(2)}:1 (need >= #{MIN_CONTRAST})"
    end

    # Custom properties here are chains of `var(--x)` indirection (e.g.
    # --button-bg-primary -> --brand -> --color-clay-600) rather than literal
    # hex values, so resolve follows the chain down to a literal hex.
    def resolve(scope, name, seen = [])
      raise "circular reference resolving #{name}" if seen.include?(name)

      value = lookup(scope, name)
      match = value.match(/\Avar\((--[\w-]+)\)\z/)
      match ? resolve(scope, match[1], seen + [ name ]) : value
    end

    def lookup(scope, name)
      [ scope_body(scope), theme_body ].each do |body|
        match = body.match(/#{Regexp.escape(name)}:\s*([^;]+);/)
        return match[1].strip if match
      end

      raise "#{name} not found in #{scope} scope or @theme"
    end

    def scope_body(scope)
      selector = scope == :root ? ":root" : ".dark"
      match = css.match(/^#{Regexp.escape(selector)}\s*\{(.*?)^\}/m)
      raise "#{selector} block not found in #{CSS_PATH}" unless match

      match[1]
    end

    def theme_body
      match = css.match(/@theme\s*\{(.*?)^\}/m)
      raise "@theme block not found in #{CSS_PATH}" unless match

      match[1]
    end

    def css
      @css ||= File.read(CSS_PATH)
    end

    def contrast_ratio(hex_a, hex_b)
      l1 = relative_luminance(hex_a)
      l2 = relative_luminance(hex_b)
      lighter, darker = [ l1, l2 ].max, [ l1, l2 ].min
      (lighter + 0.05) / (darker + 0.05)
    end

    def relative_luminance(hex)
      r, g, b = hex.delete("#").scan(/../).map { |c| c.to_i(16) / 255.0 }
      r, g, b = [ r, g, b ].map { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 }
      0.2126 * r + 0.7152 * g + 0.0722 * b
    end
end
