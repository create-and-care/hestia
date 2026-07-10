require "test_helper"

class Ui::DirectionComponentTest < ViewComponent::TestCase
  test "defaults to ltr" do
    render_inline(Ui::DirectionComponent.new) { "Content" }

    assert_selector "div[dir='ltr']", text: "Content"
  end

  test "renders a custom direction" do
    render_inline(Ui::DirectionComponent.new(dir: :rtl)) { "Content" }

    assert_selector "div[dir='rtl']", text: "Content"
  end
end
