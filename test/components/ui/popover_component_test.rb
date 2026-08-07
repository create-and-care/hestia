require "test_helper"

class Ui::PopoverComponentTest < ViewComponent::TestCase
  test "renders trigger and panel wired to the popover controller" do
    render_inline(Ui::PopoverComponent.new) do |c|
      c.with_trigger { "Open popover" }
      "Popover body"
    end

    assert_selector "[data-controller='popover']"
    assert_selector "[data-popover-target='trigger'][data-action='click->popover#toggle']", text: "Open popover"
    assert_selector "[data-popover-target='trigger'][aria-haspopup='dialog'][aria-expanded='false']", text: "Open popover"
    assert_selector "[data-popover-target='panel'][hidden][data-state='closed']", visible: false
    assert_text "Popover body"
  end

  test "trigger is linked to the panel via aria-controls/id" do
    render_inline(Ui::PopoverComponent.new) do |c|
      c.with_trigger { "Open popover" }
      "Popover body"
    end

    trigger = page.find("[data-popover-target='trigger']")
    panel = page.find("[data-popover-target='panel']", visible: false)

    assert_equal panel["id"], trigger["aria-controls"]
    assert panel["id"].present?
  end

  test "the variant swaps width and padding wholesale rather than stacking them" do
    render_inline(Ui::PopoverComponent.new) { |c| c.with_trigger { "Open" } }
    assert_selector "[data-popover-target='panel'].w-72.p-4", visible: false

    render_inline(Ui::PopoverComponent.new(variant: :menu)) { |c| c.with_trigger { "Open" } }
    classes = page.find("[data-popover-target='panel']", visible: false)["class"].split

    # Swapped, never stacked — two width (or padding) utilities on one element
    # race in the compiled stylesheet, and the DOM order of the classes on the
    # element does not decide the winner.
    assert_includes classes, "w-64"
    assert_includes classes, "p-1.5"
    refute_includes classes, "w-72"
    refute_includes classes, "p-4"
  end
end
