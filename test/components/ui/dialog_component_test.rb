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
      # The token, not the 25vh it resolves to — pinning the literal here is
      # what made the value hard to move in the first place.
      high: "mt-[var(--panel-h-offset)]",
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

  test "omits the before-visit action by default" do
    render_inline(Ui::DialogComponent.new) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    refute_selector "[data-action*='before-visit']"
  end

  test "wires up close on Turbo navigation when close_on_visit is true" do
    render_inline(Ui::DialogComponent.new(close_on_visit: true)) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    assert_selector "[data-controller='dialog'][data-action='turbo:before-visit@document->dialog#close']"
  end

  # The max-width used to live in POSITION_CLASSES, so every centered dialog was
  # max-w-md whatever it held.
  test "a centered dialog defaults to the content-column width and can be widened" do
    render_inline(Ui::DialogComponent.new) { |c| c.with_trigger { "Open" } }
    assert_selector "dialog.max-w-md", visible: :all

    render_inline(Ui::DialogComponent.new(size: :lg)) { |c| c.with_trigger { "Open" } }
    assert_selector "dialog.max-w-2xl", visible: :all
    assert_no_selector "dialog.max-w-md", visible: :all
  end

  # A side sheet is sized as a share of the screen, not as a content column, so
  # it reads from its own table.
  test "a side sheet sizes from the side table" do
    render_inline(Ui::DialogComponent.new(position: :right)) { |c| c.with_trigger { "Open" } }
    assert_selector "dialog.max-w-sm", visible: :all

    render_inline(Ui::DialogComponent.new(position: :right, size: :lg)) { |c| c.with_trigger { "Open" } }
    assert_selector "dialog.max-w-lg", visible: :all
  end

  # Anchored to both edges — a max-width would strand it off-centre.
  test "a bottom drawer takes no max-width" do
    render_inline(Ui::DialogComponent.new(position: :bottom)) { |c| c.with_trigger { "Open" } }
    assert_no_selector "dialog[class*='max-w-']", visible: :all
  end

  test "combines close_on_submit and close_on_visit into one data-action" do
    render_inline(Ui::DialogComponent.new(close_on_submit: true, close_on_visit: true)) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    assert_selector "[data-controller='dialog'][data-action='turbo:submit-end->dialog#closeOnSuccess turbo:before-visit@document->dialog#close']"
  end
end
