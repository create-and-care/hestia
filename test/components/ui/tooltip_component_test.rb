require "test_helper"

class Ui::TooltipComponentTest < ViewComponent::TestCase
  test "renders a keyboard-accessible trigger and a tooltip-role panel" do
    render_inline(Ui::TooltipComponent.new) do |c|
      c.with_trigger { "Hover me" }
      "Helpful hint"
    end

    assert_selector "[data-controller='tooltip']"
    assert_selector "[data-tooltip-target='trigger'][tabindex='0']", text: "Hover me"
    assert_selector(
      "[data-tooltip-target='trigger'][data-action='mouseenter->tooltip#show mouseleave->tooltip#hide " \
      "focus->tooltip#show blur->tooltip#hide']"
    )
    assert_selector "[data-tooltip-target='panel'][role='tooltip'][hidden][data-state='closed']", visible: false
    assert_text "Helpful hint"
  end

  test "trigger is linked to the panel via aria-describedby" do
    render_inline(Ui::TooltipComponent.new) do |c|
      c.with_trigger { "Hover me" }
      "Helpful hint"
    end

    trigger = page.find("[data-tooltip-target='trigger']")
    panel = page.find("[data-tooltip-target='panel']", visible: false)

    assert_equal panel["id"], trigger["aria-describedby"]
    assert panel["id"].present?
  end
end
