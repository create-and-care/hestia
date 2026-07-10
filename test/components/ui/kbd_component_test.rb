require "test_helper"

class Ui::KbdComponentTest < ViewComponent::TestCase
  test "renders content inside a kbd element" do
    render_inline(Ui::KbdComponent.new) { "Ctrl" }

    assert_selector "kbd.font-mono", text: "Ctrl"
  end
end
