require "test_helper"

class Ui::CopyButtonComponentTest < ViewComponent::TestCase
  test "renders a link-styled button wired to the clipboard controller" do
    render_inline(Ui::CopyButtonComponent.new(value: "ABCD-1234", label: "Copier le code"))

    assert_selector "button[type='button'][data-controller='clipboard'][data-action='clipboard#copy']" \
      "[data-clipboard-text-value='ABCD-1234']", text: "Copier le code"
  end

  test "omits clipboard-message-value when no custom message is given" do
    render_inline(Ui::CopyButtonComponent.new(value: "ABCD-1234", label: "Copier le code"))

    refute_selector "[data-clipboard-message-value]"
  end

  test "passes a custom confirmation message through to the clipboard controller" do
    render_inline(Ui::CopyButtonComponent.new(value: "token", label: "Copier", message: "Jeton copié"))

    assert_selector "[data-clipboard-message-value='Jeton copié']"
  end

  test "merges extra classes from html_options" do
    render_inline(Ui::CopyButtonComponent.new(value: "token", label: "Copier", html_options: { class: "shrink-0" }))

    assert_selector "button.shrink-0"
  end
end
