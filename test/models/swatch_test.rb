require "test_helper"

class SwatchTest < ActiveSupport::TestCase
  # Every hue the four modules offer has to be renderable. This is the test that
  # would have caught `purple` rendering in stock Tailwind for as long as it did.
  test "every colour offered by a model is a hue Swatch knows" do
    offered = (Note::COLORS + CalendarEvent::COLORS + DocumentFolder::COLORS + ServiceProviderType::COLORS).uniq
    offered -= [ Swatch::DEFAULT ]

    assert_equal [], offered - Swatch::HUES
  end

  test "every hue maps to a ramp this design system actually defines" do
    css = Rails.root.join("app/assets/stylesheets/application.tailwind.css").read

    Swatch::RAMPS.each_value do |ramp|
      # 800 and 900 specifically: a chip needs an -800 foreground and the dark
      # halves need a -900 ground, and violet had neither until it was completed.
      assert_match(/--color-#{ramp}-800:/, css, "#{ramp} is missing its 800 step")
      assert_match(/--color-#{ramp}-900:/, css, "#{ramp} is missing its 900 step")
    end
  end

  # -950 does not exist in this palette; the ramps stop at 900. Notes and
  # Calendar both reached for it, so every dark-mode swatch was off-palette.
  test "no role reaches for a shade the palette does not define" do
    shades = [ Swatch::CARD, Swatch::CHIP, Swatch::DOT, Swatch::PAPER ]
      .flat_map(&:values).compact.join(" ").scan(/-(\d{2,3})(?:\/|\b)/).flatten.map(&:to_i).uniq

    assert_equal [], shades - [ 50, 100, 200, 300, 400, 500, 600, 700, 800, 900 ]
  end

  test "the card and chip roles carry a dark half for every hue they offer" do
    Swatch::CARD.each { |hue, classes| assert_includes classes, "dark:", "card #{hue}" }
    Swatch::CHIP.each { |hue, classes| assert_includes classes, "dark:", "chip #{hue}" }
  end

  # A colour column is user-writable through the API, so an unknown value must
  # miss the table rather than be interpolated into a class name.
  test "an unknown hue renders nothing rather than a broken class" do
    assert_nil Swatch.card_classes("chartreuse")
    assert_nil Swatch.dot_classes("chartreuse")
    assert_nil Swatch.card_classes(nil)
    assert_nil Swatch.dot_classes("")
  end

  test "the roles that must always render something fall back" do
    assert_equal Swatch::CHIP.fetch("blue"), Swatch.chip_classes("chartreuse")
    assert_equal Swatch::CHIP.fetch("blue"), Swatch.chip_classes(nil)
    assert_equal Swatch::PAPER.fetch(Swatch::DEFAULT), Swatch.paper_classes(nil)
    assert_equal Swatch::PAPER.fetch(Swatch::DEFAULT), Swatch.paper_classes("default")
  end

  test "purple renders on the violet ramp, not on a colour the system never defined" do
    assert_includes Swatch.dot_classes("purple"), "violet"
    assert_not_includes Swatch.dot_classes("purple"), "purple"
  end
end
