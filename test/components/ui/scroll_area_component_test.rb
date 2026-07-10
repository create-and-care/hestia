require "test_helper"

class Ui::ScrollAreaComponentTest < ViewComponent::TestCase
  test "renders its content inside a scrollable container" do
    render_inline(Ui::ScrollAreaComponent.new) { "Scrollable content" }

    assert_selector "div.overflow-auto.rounded-md", text: "Scrollable content"
  end

  test "defaults to an h-72 height" do
    render_inline(Ui::ScrollAreaComponent.new) { "Content" }

    assert_selector "div.h-72"
  end

  test "supports a custom class name in place of the default height" do
    render_inline(Ui::ScrollAreaComponent.new(class_name: "h-40 max-h-screen")) { "Content" }

    assert_selector "div.h-40.max-h-screen.overflow-auto"
    assert_no_selector "div.h-72"
  end

  test "is keyboard-focusable so it can be scrolled without a focusable descendant" do
    render_inline(Ui::ScrollAreaComponent.new) { "Scrollable content" }

    assert_selector "div.overflow-auto[tabindex='0']"
  end
end
