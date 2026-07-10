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
end
