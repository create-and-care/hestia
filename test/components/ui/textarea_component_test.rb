require "test_helper"

class Ui::TextareaComponentTest < ViewComponent::TestCase
  test "renders textarea attributes and content" do
    render_inline(Ui::TextareaComponent.new(name: "bio", placeholder: "Tell us about yourself", rows: 6)) { "Existing bio text" }

    assert_selector "textarea[name='bio'][placeholder='Tell us about yourself'][rows='6']", text: "Existing bio text"
  end

  test "defaults to 4 rows and is enabled" do
    render_inline(Ui::TextareaComponent.new)

    assert_selector "textarea[rows='4']"
    refute_selector "textarea[disabled]"
  end

  test "renders disabled state" do
    render_inline(Ui::TextareaComponent.new(disabled: true))

    assert_selector "textarea[disabled]"
  end

  test "merges extra html_options and preserves custom classes" do
    render_inline(Ui::TextareaComponent.new(html_options: { id: "bio-field", class: "extra-class" }))

    assert_selector "textarea#bio-field.extra-class"
  end

  test "renders aria-invalid and destructive border when invalid" do
    render_inline(Ui::TextareaComponent.new(invalid: true))

    assert_selector "textarea[aria-invalid='true'].border-destructive"
  end

  test "defaults to aria-invalid false and a primary border" do
    render_inline(Ui::TextareaComponent.new)

    assert_selector "textarea[aria-invalid='false'].border-primary"
  end
end
