require "test_helper"

class Ui::MessageComponentTest < ViewComponent::TestCase
  test "renders an assistant message left-aligned with the assistant bubble variant" do
    render_inline(Ui::MessageComponent.new) { "Voici une suggestion." }

    assert_selector "div.flex.w-full.gap-3"
    assert_no_selector "div.flex-row-reverse"
    assert_selector "div.items-start"
    assert_selector "div.mr-auto.bg-surface", text: "Voici une suggestion."
  end

  test "renders a user message right-aligned with the user bubble variant" do
    render_inline(Ui::MessageComponent.new(role: :user)) { "Merci !" }

    assert_selector "div.flex-row-reverse"
    assert_selector "div.items-end"
    assert_selector "div.ml-auto.bg-button-primary", text: "Merci !"
  end

  test "defaults the display name and avatar initials by role" do
    render_inline(Ui::MessageComponent.new(role: :assistant)) { "Hey" }
    assert_selector "span", text: "A"

    render_inline(Ui::MessageComponent.new(role: :user)) { "Hey" }
    assert_selector "span", text: "V"
  end

  test "renders a custom name's initials on the avatar" do
    render_inline(Ui::MessageComponent.new(name: "Chef Bot")) { "Hey" }

    assert_selector "span", text: "CB"
  end

  test "renders the timestamp as a time element when provided" do
    render_inline(Ui::MessageComponent.new(timestamp: "10:32")) { "Hey" }

    assert_selector "time.text-subdued[datetime='10:32']", text: "10:32"
  end

  test "omits the timestamp element when not provided" do
    render_inline(Ui::MessageComponent.new) { "Hey" }

    assert_no_selector "time.text-subdued"
  end

  test "includes a screen-reader-only sender label before the bubble" do
    render_inline(Ui::MessageComponent.new(role: :user, name: "Vous")) { "Hey" }

    assert_selector "span.sr-only", text: "Vous :"
  end
end
