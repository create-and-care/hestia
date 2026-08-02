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

  private

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

    def token(scope, name)
      body = scope_body(scope)
      match = body.match(/#{Regexp.escape(name)}:\s*(#[0-9A-Fa-f]{6})\s*;/)
      raise "#{name} not found (or not a literal hex value) in #{scope} scope" unless match

      match[1]
    end

    def scope_body(scope)
      @css ||= File.read(CSS_PATH)
      selector = scope == :root ? ":root" : ".dark"
      match = @css.match(/^#{Regexp.escape(selector)}\s*\{(.*?)^\}/m)
      raise "#{selector} block not found in #{CSS_PATH}" unless match

      match[1]
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
