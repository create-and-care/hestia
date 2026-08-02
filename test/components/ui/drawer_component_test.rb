require "test_helper"

class Ui::DrawerComponentTest < ViewComponent::TestCase
  test "renders trigger, title, description and footer through the underlying dialog" do
    render_inline(Ui::DrawerComponent.new) do |c|
      c.with_trigger { "Open drawer" }
      c.with_title { "Filters" }
      c.with_description { "Narrow down results" }
      c.with_footer { "Apply" }
      "Drawer body"
    end

    assert_selector "[data-controller='dialog']"
    assert_selector "[data-action='click->dialog#open']", text: "Open drawer"
    assert_selector "dialog[data-dialog-target='dialog'][data-state='closed']"
    assert_selector "dialog[role='dialog']"
    assert_selector "dialog[data-action='click->dialog#closeOnBackdrop cancel->dialog#onCancel']"
    assert_selector "h2", text: "Filters"
    assert_selector "p", text: "Narrow down results"
    assert_text "Apply"
    assert_text "Drawer body"
  end

  test "slides in from the bottom (DialogComponent position: :bottom)" do
    render_inline(Ui::DrawerComponent.new) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    assert_includes rendered_content, "rounded-t-lg"
    assert_includes rendered_content, "slide-in-from-bottom"
  end

  test "renders every valid side without raising" do
    fragments = {
      left: "rounded-r-lg",
      right: "rounded-l-lg",
      bottom: "rounded-t-lg"
    }

    fragments.each do |side, fragment|
      render_inline(Ui::DrawerComponent.new(side: side)) do |c|
        c.with_trigger { "Open" }
        "Body"
      end

      assert_selector "dialog"
      assert_includes rendered_content, fragment
    end
  end

  test "omits title, description and footer when their slots are not given" do
    render_inline(Ui::DrawerComponent.new) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    refute_selector "h2"
    refute_selector "p"
  end

  test "forwards close_on_visit to the underlying dialog" do
    render_inline(Ui::DrawerComponent.new(side: :left, close_on_visit: true)) do |c|
      c.with_trigger { "Open" }
      "Body"
    end

    assert_selector "[data-controller='dialog'][data-action='turbo:before-visit@document->dialog#close']"
  end
end
