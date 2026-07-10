require "test_helper"

class Ui::SeparatorComponentTest < ViewComponent::TestCase
  test "renders a horizontal separator by default" do
    render_inline(Ui::SeparatorComponent.new)

    assert_selector "div[role='separator'].h-px.w-full"
    assert_no_selector "div[aria-orientation]"
  end

  test "renders a vertical separator" do
    render_inline(Ui::SeparatorComponent.new(orientation: :vertical))

    assert_selector "div[role='separator'][aria-orientation='vertical'].w-px.h-full"
  end
end
