require "test_helper"

class Ui::SwitchComponentTest < ViewComponent::TestCase
  test "renders an unchecked switch by default" do
    render_inline(Ui::SwitchComponent.new(name: "notifications"))

    assert_selector "input[type='checkbox'][role='switch'][name='notifications']"
    assert_no_selector "input[checked]"
    assert_no_selector "input[disabled]"
  end

  test "renders a checked switch" do
    render_inline(Ui::SwitchComponent.new(checked: true))

    assert_selector "input[type='checkbox'][checked]"
  end

  test "renders a disabled switch" do
    render_inline(Ui::SwitchComponent.new(disabled: true))

    assert_selector "input[type='checkbox'][disabled]"
  end

  test "wraps the input in a label associated by id" do
    render_inline(Ui::SwitchComponent.new(id: "my-switch"))

    assert_selector "label[for='my-switch'] input#my-switch[type='checkbox']"
  end

  test "generates a random id when none given" do
    render_inline(Ui::SwitchComponent.new)

    assert_selector "input[id^='switch-']"
  end
end
