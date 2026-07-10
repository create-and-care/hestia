require "test_helper"

class Ui::SonnerComponentTest < ViewComponent::TestCase
  test "renders a fixed, pointer-events-none toast viewport wired to the sonner controller" do
    render_inline(Ui::SonnerComponent.new)

    assert_selector "div[data-controller='sonner'].pointer-events-none.fixed.bottom-4.right-4"
  end

  test "renders as an empty viewport; toasts are appended client-side by the controller" do
    render_inline(Ui::SonnerComponent.new)

    assert_selector "div[data-controller='sonner']", count: 1
  end

  test "announces newly appended toasts to screen readers via a live region on the viewport" do
    render_inline(Ui::SonnerComponent.new)

    assert_selector "div[data-controller='sonner'][role='status'][aria-live='polite']"
  end
end
