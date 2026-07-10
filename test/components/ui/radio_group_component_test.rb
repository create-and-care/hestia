require "test_helper"

class Ui::RadioGroupComponentTest < ViewComponent::TestCase
  OPTIONS = [ [ "Small", "sm" ], [ "Medium", "md" ], [ "Large", "lg" ] ].freeze

  test "renders a radiogroup with a radio input per option" do
    render_inline(Ui::RadioGroupComponent.new(name: "size", options: OPTIONS))

    assert_selector "div[role='radiogroup']"
    assert_selector "input[type='radio'][name='size']", count: 3
  end

  test "labels are associated with their input via for/id" do
    render_inline(Ui::RadioGroupComponent.new(name: "size", options: OPTIONS))

    assert_selector "label[for='size-sm']", text: "Small"
    assert_selector "input#size-sm[type='radio'][value='sm']"
  end

  test "marks the selected option as checked and leaves others unchecked" do
    render_inline(Ui::RadioGroupComponent.new(name: "size", options: OPTIONS, selected: "md"))

    assert_selector "input#size-md[checked]"
    refute_selector "input#size-sm[checked]"
    refute_selector "input#size-lg[checked]"
  end

  test "no option is checked when nothing is selected" do
    render_inline(Ui::RadioGroupComponent.new(name: "size", options: OPTIONS))

    refute_selector "input[checked]"
  end
end
