require "test_helper"

class Ui::CollapsibleComponentTest < ViewComponent::TestCase
  test "renders trigger slot and main content" do
    render_inline(Ui::CollapsibleComponent.new) do |c|
      c.with_trigger { "Show details" }
      "Panel body text"
    end

    assert_selector "div[data-controller='collapsible']"
    assert_selector "button[data-collapsible-target='trigger']", text: "Show details"
    assert_selector "div[data-collapsible-target='panel']", text: "Panel body text", visible: :all
  end

  test "trigger is a real button with aria-expanded false by default" do
    render_inline(Ui::CollapsibleComponent.new) do |c|
      c.with_trigger { "Toggle" }
      "Body"
    end

    assert_selector "button[data-collapsible-target='trigger'][type='button'][aria-expanded='false']"
    assert_selector "button[data-collapsible-target='trigger'][data-action='click->collapsible#toggle']"
    refute_selector "[data-collapsible-target='trigger'][role]"
    refute_selector "[data-collapsible-target='trigger'][tabindex]"
  end

  test "trigger is linked to the panel via aria-controls/id" do
    render_inline(Ui::CollapsibleComponent.new) do |c|
      c.with_trigger { "Toggle" }
      "Body"
    end

    trigger = page.find("[data-collapsible-target='trigger']")
    panel = page.find("[data-collapsible-target='panel']", visible: :all)

    assert_equal panel["id"], trigger["aria-controls"]
    assert panel["id"].present?
  end

  test "panel starts hidden and closed" do
    render_inline(Ui::CollapsibleComponent.new) do |c|
      c.with_trigger { "Toggle" }
      "Body"
    end

    assert_selector "div[data-collapsible-target='panel'][hidden][data-state='closed']", visible: :all
  end

  test "open: true starts the panel expanded" do
    render_inline(Ui::CollapsibleComponent.new(open: true)) do |c|
      c.with_trigger { "Toggle" }
      "Body"
    end

    assert_selector "button[data-collapsible-target='trigger'][aria-expanded='true']"
    assert_selector "div[data-collapsible-target='panel'][data-state='open']"
    refute_selector "div[data-collapsible-target='panel'][hidden]", visible: :all
  end
end
