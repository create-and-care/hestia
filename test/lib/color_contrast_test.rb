require "test_helper"

# Guards against a state token being visually indistinguishable from a
# neighboring one, resolved values compared as CIE76 ΔE — not by asserting
# the token names differ, which is exactly the check that let --item-active
# get introduced as a literal duplicate of --surface-inset-hover without
# anyone noticing it was ~0-1.5 ΔE from --surface-hover (imperceptible).
class ColorContrastTest < ActiveSupport::TestCase
  MIN_DELTA_E = 4.0

  CSS_PATH = Rails.root.join("app/assets/stylesheets/application.tailwind.css")

  test "--item-active is perceptibly distinct from --surface-hover in light mode" do
    assert_distinct(:root_token, "--item-active", "--surface-hover")
  end

  test "--item-active is perceptibly distinct from --surface-hover in dark mode" do
    assert_distinct(:dark_token, "--item-active", "--surface-hover")
  end

  # ── WCAG AA on the pairs the app actually paints ─────────────────────────
  # Distinctness is one question; legibility is the other, and it is the one
  # visual:check kept failing on. These are the exact pairs it measured under
  # 4.5:1 — a token pair is a contract, and this is where the contract lives
  # rather than in a screenshot pass that takes twenty minutes to run.
  WCAG_AA_NORMAL = 4.5

  # --destructive-text on --destructive-subtle is the calendar's public-holiday
  # cell: the tint is the background, the token named "-text" is what goes on
  # it. That is the whole rule the token pair encodes.
  test "status text clears AA on its own tint, in both themes" do
    assert_readable(:root, "--destructive-text", "--destructive-subtle")
    assert_readable(:dark, "--destructive-text", "--destructive-subtle")
  end

  # A form's help text lands on an inset panel more often than on the page
  # background, and the quieter token is the one that gets used there.
  test "the muted text tokens clear AA on the inset surface, in both themes" do
    %w[--text-subdued --text-secondary].each do |token|
      assert_readable(:root, token, "--surface-inset")
      assert_readable(:dark, token, "--surface-inset")
    end
  end

  test "every text token clears AA on the page background, in both themes" do
    %w[--text-primary --text-secondary --text-subdued].each do |token|
      assert_readable(:root, token, "--surface")
      assert_readable(:dark, token, "--surface")
    end
  end

  private

    def assert_readable(scope, foreground, background)
      fg = token(scope, foreground)
      bg = token(scope, background)
      ratio = contrast_ratio(fg, bg)

      assert_operator ratio, :>=, WCAG_AA_NORMAL,
        "#{foreground} (#{fg}) on #{background} (#{bg}) in #{scope} is #{ratio.round(2)}:1, " \
        "under the #{WCAG_AA_NORMAL}:1 floor for normal-size text"
    end

    def contrast_ratio(hex_a, hex_b)
      l1, l2 = relative_luminance(hex_a), relative_luminance(hex_b)
      ([ l1, l2 ].max + 0.05) / ([ l1, l2 ].min + 0.05)
    end

    def relative_luminance(hex)
      hex_to_rgb(hex)
        .map { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 }
        .zip([ 0.2126, 0.7152, 0.0722 ]).sum { |channel, weight| channel * weight }
    end

    def assert_distinct(scope_method, name_a, name_b)
      hex_a = send(scope_method, name_a)
      hex_b = send(scope_method, name_b)
      delta = delta_e76(hex_a, hex_b)

      assert_operator delta, :>=, MIN_DELTA_E,
        "#{name_a} (#{hex_a}) and #{name_b} (#{hex_b}) are only #{delta.round(2)} ΔE apart " \
        "(need >= #{MIN_DELTA_E}) — they'd read as the same background"
    end

    def root_token(name) = token(:root, name)
    def dark_token(name) = token(:dark, name)

    # Resolves a token to a literal hex, following `var()` indirection.
    #
    # Half the palette is written as `--destructive-text: var(--color-crimson-800)`,
    # and the indirection is the point — it is what lets a theme be re-pointed
    # without touching call sites. A test that only read literals could not see
    # those tokens at all, which is precisely where the contrast bugs were.
    def token(scope, name, depth = 0)
      raise "#{name}: var() chain too deep, probably a cycle" if depth > 5

      value = raw_value(scope, name) || raw_value(:root, name) || raw_value(:theme, name)
      raise "#{name} not found in #{scope} scope" if value.nil?
      return value.upcase if value.match?(/\A#[0-9A-Fa-f]{6}\z/)

      reference = value[/var\(\s*(--[\w-]+)\s*\)/, 1]
      raise "#{name} resolves to #{value.inspect}, which is neither a hex nor a var()" if reference.nil?

      token(scope, reference, depth + 1)
    end

    def raw_value(scope, name)
      scope_body(scope)[/#{Regexp.escape(name)}:\s*([^;]+);/, 1]&.strip
    end

    SCOPE_SELECTORS = { root: ":root", dark: ".dark", theme: "@theme" }.freeze

    def scope_body(scope)
      @css ||= File.read(CSS_PATH)
      @scope_bodies ||= {}
      @scope_bodies[scope] ||= begin
        selector = SCOPE_SELECTORS.fetch(scope)
        match = @css.match(/^#{Regexp.escape(selector)}\s*\{(.*?)^\}/m)
        raise "#{selector} block not found in #{CSS_PATH}" unless match

        match[1]
      end
    end

    # CIE76 ΔE — Euclidean distance in CIELAB. Coarser than ΔE2000, but the
    # thresholds here (imperceptible vs. clearly-distinct) are well outside
    # the range where the two formulas disagree.
    def delta_e76(hex_a, hex_b)
      l1, a1, b1 = lab(hex_a)
      l2, a2, b2 = lab(hex_b)
      Math.sqrt((l1 - l2)**2 + (a1 - a2)**2 + (b1 - b2)**2)
    end

    def lab(hex)
      xyz_to_lab(*rgb_to_xyz(*hex_to_rgb(hex)))
    end

    def hex_to_rgb(hex)
      hex.delete("#").scan(/../).map { |c| c.to_i(16) / 255.0 }
    end

    def rgb_to_xyz(r, g, b)
      r, g, b = [ r, g, b ].map { |c| c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 }

      [
        r * 0.4124564 + g * 0.3575761 + b * 0.1804375,
        r * 0.2126729 + g * 0.7151522 + b * 0.0721750,
        r * 0.0193339 + g * 0.1191920 + b * 0.9503041
      ]
    end

    def xyz_to_lab(x, y, z)
      xn, yn, zn = 0.95047, 1.0, 1.08883
      fx, fy, fz = [ x / xn, y / yn, z / zn ].map { |t| t > (6.0 / 29)**3 ? t**(1.0 / 3) : (t / (3 * (6.0 / 29)**2)) + 4.0 / 29 }

      [ 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz) ]
    end
end
