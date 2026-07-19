require "test_helper"

class Ui::MessageScrollerComponentTest < ViewComponent::TestCase
  test "wraps content in the stimulus controller with a scrollable viewport target" do
    render_inline(Ui::MessageScrollerComponent.new) { "<p class='msg'>Salut</p>".html_safe }

    assert_selector "div[data-controller='message-scroller']"
    assert_selector "div[data-message-scroller-target='viewport'][data-action='scroll->message-scroller#handleScroll']"
    assert_selector "[data-message-scroller-target='viewport'] p.msg", text: "Salut"
  end

  test "applies the default height class to the viewport" do
    render_inline(Ui::MessageScrollerComponent.new) { "content" }

    assert_selector "[data-message-scroller-target='viewport'].h-80"
  end

  test "applies a custom class_name to the viewport" do
    render_inline(Ui::MessageScrollerComponent.new(class_name: "h-40 max-h-96")) { "content" }

    assert_selector "[data-message-scroller-target='viewport'].h-40.max-h-96"
  end

  test "renders a jump-to-bottom button wired to the scroller controller, hidden by default" do
    render_inline(Ui::MessageScrollerComponent.new) { "content" }

    assert_selector "button[data-message-scroller-target='jumpButton'][data-action='click->message-scroller#scrollToBottom'][hidden]", visible: :all, text: "Nouveaux messages"
  end

  test "viewport is announced as a live log region for screen readers" do
    render_inline(Ui::MessageScrollerComponent.new) { "<p class='msg'>Salut</p>".html_safe }

    assert_selector "[data-message-scroller-target='viewport'][role='log'][aria-live='polite']"
  end

  test "viewport is keyboard-focusable so it can be scrolled without a mouse" do
    render_inline(Ui::MessageScrollerComponent.new) { "content" }

    assert_selector "[data-message-scroller-target='viewport'][tabindex='0']"
  end

  test "jump-to-bottom button is wrapped so its appearance is announced" do
    render_inline(Ui::MessageScrollerComponent.new) { "content" }

    assert_selector "[role='status'][aria-live='polite'][aria-atomic='true'] button[data-message-scroller-target='jumpButton']", visible: :all
  end
end
