require "test_helper"

class Ui::ButtonToComponentTest < ViewComponent::TestCase
  test "renders a button_to with the outline/sm classes by default" do
    render_inline(Ui::ButtonToComponent.new("/widgets/1")) { "Delete" }

    assert_selector "form[action='/widgets/1'][method='post']" do
      assert_selector "button.border-primary", text: "Delete"
    end
  end

  test "renders the given HTTP method as a hidden field" do
    render_inline(Ui::ButtonToComponent.new("/widgets/1", method: :delete)) { "Delete" }

    assert_selector "form input[name='_method'][value='delete']", visible: false
  end

  test "supports a variant and forwards form html_options (e.g. turbo_confirm)" do
    render_inline(Ui::ButtonToComponent.new("/widgets/1", method: :delete, variant: :destructive,
      html_options: { form: { data: { turbo_confirm: "Sure?" } } })) { "Delete" }

    assert_selector "form[data-turbo-confirm='Sure?']"
    assert_selector "button.bg-button-destructive", text: "Delete"
  end
end
