require "test_helper"

class Ui::ResizableComponentTest < ViewComponent::TestCase
  test "renders the first and second panes with their slot content" do
    render_inline(Ui::ResizableComponent.new) do |resizable|
      resizable.with_first { "Left pane" }
      resizable.with_second { "Right pane" }
    end

    assert_selector "div[data-controller='resizable']"
    assert_selector "div[data-resizable-target='first']", text: "Left pane"
    assert_text "Right pane"
  end

  test "renders the drag handle wired to the pointerdown and keydown actions" do
    render_inline(Ui::ResizableComponent.new) do |resizable|
      resizable.with_first { "Left" }
      resizable.with_second { "Right" }
    end

    assert_selector "div[data-action*='pointerdown->resizable#startDrag']"
    assert_selector "div[data-action*='keydown->resizable#nudge']"
  end

  test "the drag handle is a focusable separator exposing its current split as an ARIA value" do
    render_inline(Ui::ResizableComponent.new) do |resizable|
      resizable.with_first { "Left" }
      resizable.with_second { "Right" }
    end

    assert_selector "div[data-resizable-target='handle'][role='separator'][aria-orientation='vertical'][tabindex='0']"
    assert_selector "div[data-resizable-target='handle'][aria-valuenow='50'][aria-valuemin='0'][aria-valuemax='100']"
  end

  test "renders an empty shell without raising when no slots are given" do
    render_inline(Ui::ResizableComponent.new)

    assert_selector "div[data-controller='resizable']"
    assert_selector "div[data-resizable-target='first']"
  end
end
