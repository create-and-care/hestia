require "test_helper"

class Ui::LabelComponentTest < ViewComponent::TestCase
  test "renders a label with content" do
    render_inline(Ui::LabelComponent.new) { "Email address" }

    assert_selector "label.text-sm", text: "Email address"
  end

  test "renders the for attribute when for_id is given" do
    render_inline(Ui::LabelComponent.new(for_id: "email-field")) { "Email" }

    assert_selector "label[for='email-field']", text: "Email"
  end

  test "merges custom html_options including class and id" do
    render_inline(Ui::LabelComponent.new(html_options: { id: "my-label", class: "extra-class" })) { "Name" }

    assert_selector "label#my-label.extra-class.text-sm", text: "Name"
  end
end
