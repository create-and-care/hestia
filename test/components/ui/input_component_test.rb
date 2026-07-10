require "test_helper"

class Ui::InputComponentTest < ViewComponent::TestCase
  test "renders a text input with the given attributes" do
    render_inline(Ui::InputComponent.new(name: "q", value: "hello", placeholder: "Search"))

    assert_selector "input[type='text'][name='q'][value='hello'][placeholder='Search']"
  end

  test "is enabled and marked valid by default" do
    render_inline(Ui::InputComponent.new)

    assert_selector "input[aria-invalid='false']"
    refute_selector "input[disabled]"
    assert_selector "input.border-primary"
  end

  test "renders disabled state" do
    render_inline(Ui::InputComponent.new(disabled: true))

    assert_selector "input[disabled]"
  end

  test "renders invalid state with aria-invalid and destructive styling" do
    render_inline(Ui::InputComponent.new(invalid: true))

    assert_selector "input[aria-invalid='true'].border-destructive"
  end

  test "merges extra html_options and preserves custom classes" do
    render_inline(Ui::InputComponent.new(html_options: { id: "search-field", class: "extra-class", data: { testid: "search" } }))

    assert_selector "input#search-field.extra-class[data-testid='search']"
  end

  test "supports alternate input types" do
    render_inline(Ui::InputComponent.new(type: "email"))

    assert_selector "input[type='email']"
  end
end
