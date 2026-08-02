require "test_helper"

# Guards the design-system rule that icon-only buttons go through
# Ui::ButtonComponent (variant: :ghost) instead of a hand-rolled <button>. A
# hand-rolled one skips the shared VARIANTS/SIZES table entirely, which is how
# dialog/calendar/attachment/carousel/celebration_moment all independently
# ended up under the 36px touch-target floor — the same mistake, once per
# component, because nothing stopped it from being made again.
class IconOnlyButtonTest < ActiveSupport::TestCase
  OPEN_TAG = /<button\b(?:[^>"']|"[^"]*"|'[^']*')*>/
  BUTTON = /#{OPEN_TAG}(.*?)<\/button>/m
  ICON_ONLY_INNER = /\A(<svg\b.*?<\/svg>|<%=\s*lucide_icon(?:_mask)?\([^)]*\)\s*%>)\z/m

  test "no hand-rolled icon-only <button> outside Ui::ButtonComponent" do
    offenders = Dir.glob(Rails.root.join("app/components/**/*.erb")).flat_map do |path|
      content = File.read(path)
      content.scan(BUTTON).filter_map do |(inner)|
        relative_path(path) if inner.strip.match?(ICON_ONLY_INNER)
      end
    end

    assert_empty offenders,
      "Hand-rolled icon-only <button> found outside Ui::ButtonComponent — " \
      "render Ui::ButtonComponent.new(variant: :ghost, size: :sm) with an aria-label instead:\n#{offenders.join("\n")}"
  end

  private

    def relative_path(path)
      path.to_s.sub("#{Rails.root}/", "")
    end
end
