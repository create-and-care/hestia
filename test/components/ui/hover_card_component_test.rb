require "test_helper"

class Ui::HoverCardComponentTest < ViewComponent::TestCase
  test "renders trigger and hover card panel wired for mouseenter/mouseleave" do
    render_inline(Ui::HoverCardComponent.new) do |c|
      c.with_trigger { "@jane" }
      "Jane Doe -- Product designer"
    end

    assert_selector "[data-controller='hover-card']"
    assert_selector(
      "[data-hover-card-target='trigger'][tabindex='0']" \
      "[data-action='mouseenter->hover-card#show mouseleave->hover-card#hide focus->hover-card#show blur->hover-card#hide']",
      text: "@jane"
    )
    assert_selector(
      "[data-hover-card-target='panel'][hidden][data-state='closed']" \
      "[data-action='mouseenter->hover-card#show mouseleave->hover-card#hide']",
      visible: false
    )
    assert_text "Jane Doe -- Product designer"
  end

  test "trigger is keyboard-focusable and linked to the panel via aria-describedby" do
    render_inline(Ui::HoverCardComponent.new) do |c|
      c.with_trigger { "@jane" }
      "Jane Doe -- Product designer"
    end

    trigger = page.find("[data-hover-card-target='trigger']")
    panel = page.find("[data-hover-card-target='panel']", visible: false)

    assert_equal panel["id"], trigger["aria-describedby"]
    assert panel["id"].present?
  end
end
