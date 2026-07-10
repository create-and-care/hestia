require "test_helper"

class Ui::AspectRatioComponentTest < ViewComponent::TestCase
  test "renders the default 16:9 ratio" do
    render_inline(Ui::AspectRatioComponent.new) { "Media" }

    assert_selector "div[style*='aspect-ratio: 1.777']"
    assert_text "Media"
  end

  test "renders a custom ratio" do
    render_inline(Ui::AspectRatioComponent.new(ratio: 2)) { "Square" }

    assert_selector "div[style*='aspect-ratio: 2']"
  end

  test "wraps content in an absolutely positioned inset container" do
    render_inline(Ui::AspectRatioComponent.new) { "Media" }

    assert_selector "div.relative.overflow-hidden > div.absolute.inset-0", text: "Media"
  end
end
