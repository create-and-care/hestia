require "test_helper"

class Ui::CheckboxComponentTest < ViewComponent::TestCase
  test "renders an unchecked checkbox by default" do
    render_inline(Ui::CheckboxComponent.new(name: "terms"))

    assert_selector "input[type='checkbox'][name='terms']"
    assert_no_selector "input[checked]"
    assert_no_selector "input[disabled]"
  end

  test "renders a checked checkbox" do
    render_inline(Ui::CheckboxComponent.new(checked: true))

    assert_selector "input[type='checkbox'][checked]"
  end

  test "renders a disabled checkbox" do
    render_inline(Ui::CheckboxComponent.new(disabled: true))

    assert_selector "input[type='checkbox'][disabled]"
  end

  test "generates a random id when none given" do
    render_inline(Ui::CheckboxComponent.new)

    assert_selector "input[id^='checkbox-']"
  end

  test "uses a custom id when given" do
    render_inline(Ui::CheckboxComponent.new(id: "my-checkbox"))

    assert_selector "input#my-checkbox[type='checkbox']"
  end

  test "renders the checkmark svg icon" do
    render_inline(Ui::CheckboxComponent.new)

    assert_selector "svg path"
  end
end
