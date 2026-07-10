require "test_helper"

class Ui::ToggleComponentTest < ViewComponent::TestCase
  test "renders an unpressed toggle by default" do
    render_inline(Ui::ToggleComponent.new) { "B" }

    assert_selector "button[type='button'][aria-pressed='false']", text: "B"
  end

  test "renders a pressed toggle" do
    render_inline(Ui::ToggleComponent.new(pressed: true)) { "B" }

    assert_selector "button[aria-pressed='true']", text: "B"
  end

  test "wires up the toggle stimulus controller" do
    render_inline(Ui::ToggleComponent.new) { "B" }

    assert_selector "button[data-controller='toggle'][data-action='click->toggle#toggle']"
  end
end
