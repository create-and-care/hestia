require "test_helper"

class Ui::NativeSelectComponentTest < ViewComponent::TestCase
  test "renders an option for each entry" do
    render_inline(Ui::NativeSelectComponent.new(name: "color", options: [ "Red", "Green", "Blue" ]))

    assert_selector "select[name='color']"
    assert_selector "option", count: 3
    assert_selector "option[value='Red']", text: "Red"
  end

  test "supports label/value pairs and marks the selected option" do
    render_inline(Ui::NativeSelectComponent.new(
      options: [ [ "Red", "r" ], [ "Green", "g" ] ],
      selected: "g"
    ))

    assert_selector "option[value='r']", text: "Red"
    refute_selector "option[value='r'][selected]"
    assert_selector "option[value='g'][selected]", text: "Green"
  end

  test "renders disabled state" do
    render_inline(Ui::NativeSelectComponent.new(disabled: true))

    assert_selector "select[disabled]"
  end

  test "merges extra html_options and preserves custom classes" do
    render_inline(Ui::NativeSelectComponent.new(html_options: { id: "country", class: "extra-class" }))

    assert_selector "select#country.extra-class"
  end

  test "renders aria-invalid and destructive border when invalid" do
    render_inline(Ui::NativeSelectComponent.new(invalid: true))

    assert_selector "select[aria-invalid='true'].border-destructive"
  end

  test "defaults to aria-invalid false and a primary border" do
    render_inline(Ui::NativeSelectComponent.new)

    assert_selector "select[aria-invalid='false'].border-primary"
  end
end
