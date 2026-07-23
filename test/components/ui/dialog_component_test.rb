require "test_helper"

class Ui::DialogComponentTest < ViewComponent::TestCase
  test "renders trigger, title, description, footer and body content" do
    render_inline(Ui::DialogComponent.new) do |c|
      c.with_trigger { "Open dialog" }
      c.with_title { "Delete item" }
      c.with_description { "This cannot be undone." }
      c.with_footer { "Footer actions" }
      "Body copy"
    end

    assert_selector "[data-controller='dialog']"
    assert_selector "[data-action='click->dialog#open']", text: "Open dialog"
    assert_selector "dialog[data-dialog-target='dialog']"
    assert_selector "dialog[data-state='closed']"
    assert_selector "dialog[role='dialog']"
    assert_selector "dialog[data-action='click->dialog#closeOnBackdrop cancel->dialog#onCancel']"
    assert_selector "h2", text: "Delete item"
    assert_selector "p", text: "This cannot be undone."
    assert_selector "button[aria-label='Close'][data-action='click->dialog#close']"
    assert_text "Footer actions"
    assert_text "Body copy"
  end

  test "omits title, description and footer when their slots are not given" do
    render_inline(Ui::DialogComponent.new) do |c|
      c.with_trigger { "Open" }
      "Body only"
    end

    refute_selector "h2"
    refute_selector "p"
    refute_selector "div.flex.items-center.justify-end.gap-2"
  end

  test "renders every POSITION_CLASSES variant without raising" do
    fragments = {
      center: "max-w-md",
      high: "mt-[25vh]",
      right: "rounded-l-lg",
      left: "rounded-r-lg",
      bottom: "rounded-t-lg"
    }

    Ui::DialogComponent::POSITION_CLASSES.each_key do |position|
      render_inline(Ui::DialogComponent.new(position: position)) do |c|
        c.with_trigger { "Open" }
        "Body"
      end

      assert_selector "dialog"
      assert_includes rendered_content, fragments.fetch(position)
    end
  end

  test "raises for an unknown position" do
    assert_raises(KeyError) do
      render_inline(Ui::DialogComponent.new(position: :nope)) do |c|
        c.with_trigger { "Open" }
      end
    end
  end

  test "omits the submit-end action by default" do
    render_inline(Ui::DialogComponent.new) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    refute_selector "[data-action*='submit-end']"
  end

  test "wires up closeOnSuccess when close_on_submit is true" do
    render_inline(Ui::DialogComponent.new(close_on_submit: true)) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    assert_selector "[data-controller='dialog'][data-action='turbo:submit-end->dialog#closeOnSuccess']"
  end
end
