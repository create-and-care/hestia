require "test_helper"

class Ui::SheetComponentTest < ViewComponent::TestCase
  test "renders trigger, title, description and footer through the underlying dialog" do
    render_inline(Ui::SheetComponent.new) do |c|
      c.with_trigger { "Open sheet" }
      c.with_title { "Settings" }
      c.with_description { "Manage your preferences" }
      c.with_footer { "Save" }
      "Sheet body"
    end

    assert_selector "[data-controller='dialog']"
    assert_selector "[data-action='click->dialog#open']", text: "Open sheet"
    assert_selector "dialog[data-dialog-target='dialog'][data-state='closed']"
    assert_selector "dialog[role='dialog']"
    assert_selector "dialog[data-action='click->dialog#closeOnBackdrop cancel->dialog#onCancel']"
    assert_selector "h2", text: "Settings"
    assert_selector "p", text: "Manage your preferences"
    assert_text "Save"
    assert_text "Sheet body"
  end

  test "defaults to sliding in from the right" do
    render_inline(Ui::SheetComponent.new) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    assert_includes rendered_content, "rounded-l-lg"
    assert_includes rendered_content, "slide-in-from-right"
  end

  test "renders every valid side without raising" do
    fragments = {
      left: "rounded-r-lg",
      right: "rounded-l-lg",
      bottom: "rounded-t-lg",
      center: "max-w-md"
    }

    fragments.each do |side, fragment|
      render_inline(Ui::SheetComponent.new(side: side)) do |c|
        c.with_trigger { "Open" }
        "Body"
      end

      assert_selector "dialog"
      assert_includes rendered_content, fragment
    end
  end
end
