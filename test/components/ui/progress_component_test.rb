require "test_helper"

class Ui::ProgressComponentTest < ViewComponent::TestCase
  test "renders progressbar semantics for the given value" do
    render_inline(Ui::ProgressComponent.new(value: 40))

    assert_selector "div[role='progressbar'][aria-valuenow='40'][aria-valuemin='0'][aria-valuemax='100']"
    assert_selector "div[role='progressbar'] > div[style*='width: 40.0%']"
  end

  test "defaults to zero" do
    render_inline(Ui::ProgressComponent.new)

    assert_selector "div[aria-valuenow='0']"
    assert_selector "div[style*='width: 0.0%']"
  end

  test "clamps the value to the given max" do
    render_inline(Ui::ProgressComponent.new(value: 150, max: 50))

    assert_selector "div[aria-valuenow='50'][aria-valuemax='50']"
    assert_selector "div[style*='width: 100.0%']"
  end
end
