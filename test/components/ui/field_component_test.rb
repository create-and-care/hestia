require "test_helper"

class Ui::FieldComponentTest < ViewComponent::TestCase
  test "associates the label with the given id" do
    render_inline(Ui::FieldComponent.new(id: "email")) do |c|
      c.with_label { "Email" }
      c.with_control { "<input id=\"email\" type=\"email\">".html_safe }
    end

    assert_selector "label[for='email']", text: "Email"
    assert_selector "input#email"
  end

  test "renders description when there is no error" do
    render_inline(Ui::FieldComponent.new) do |c|
      c.with_control { "<input type=\"text\">".html_safe }
      c.with_description { "We'll never share your email" }
    end

    assert_selector "p.text-secondary", text: "We'll never share your email"
    refute_selector "p.text-destructive"
  end

  test "error replaces the description when both are present" do
    render_inline(Ui::FieldComponent.new) do |c|
      c.with_control { "<input type=\"text\">".html_safe }
      c.with_description { "We'll never share your email" }
      c.with_error { "Email is invalid" }
    end

    assert_selector "p.text-destructive", text: "Email is invalid"
    refute_text "We'll never share your email"
  end

  test "renders without a label when the slot is absent" do
    render_inline(Ui::FieldComponent.new) do |c|
      c.with_control { "<input type=\"text\">".html_safe }
    end

    refute_selector "label"
  end

  test "exposes description_id/error_id for callers to wire aria-describedby" do
    render_inline(Ui::FieldComponent.new(id: "email")) do |c|
      c.with_control { %(<input id="email" type="email" aria-describedby="#{c.error_id}">).html_safe }
      c.with_error { "Email is invalid" }
    end

    assert_selector "p#email-error.text-destructive", text: "Email is invalid"
    assert_selector "input#email[aria-describedby='email-error']"
  end

  test "description_id/error_id are nil without an id" do
    field = Ui::FieldComponent.new

    assert_nil field.description_id
    assert_nil field.error_id
  end
end
