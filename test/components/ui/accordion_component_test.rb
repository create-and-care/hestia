require "test_helper"

class Ui::AccordionComponentTest < ViewComponent::TestCase
  test "renders default (single-open) accordion with items" do
    render_inline(Ui::AccordionComponent.new) do |c|
      c.with_item(title: "Item 1", key: "item-1") { "Panel 1 content" }
      c.with_item(title: "Item 2", key: "item-2") { "Panel 2 content" }
    end

    assert_selector "div[data-controller='accordion']"
    assert_selector "div[data-accordion-multiple-value='false']"
    assert_selector "button[data-accordion-target='trigger'][data-key='item-1']", text: "Item 1"
    assert_selector "button[data-accordion-target='trigger'][data-key='item-2']", text: "Item 2"
    assert_selector "div[data-accordion-target='panel'][data-key='item-1']", text: "Panel 1 content", visible: :all
    assert_selector "div[data-accordion-target='panel'][data-key='item-2']", text: "Panel 2 content", visible: :all
  end

  test "renders multiple-value true when multiple: true" do
    render_inline(Ui::AccordionComponent.new(multiple: true)) do |c|
      c.with_item(title: "Item 1", key: "item-1") { "Panel 1" }
    end

    assert_selector "div[data-accordion-multiple-value='true']"
  end

  test "trigger has button semantics and aria-expanded false by default" do
    render_inline(Ui::AccordionComponent.new) do |c|
      c.with_item(title: "Item 1", key: "item-1") { "Panel 1" }
    end

    assert_selector "button[type='button'][aria-expanded='false']"
    assert_selector "button[data-action='click->accordion#toggle']"
  end

  test "panel is hidden and closed by default" do
    render_inline(Ui::AccordionComponent.new) do |c|
      c.with_item(title: "Item 1", key: "item-1") { "Panel 1" }
    end

    assert_selector "div[data-accordion-target='panel'][hidden][data-state='closed']", visible: :all
  end

  test "trigger's aria-controls points at the panel's id" do
    render_inline(Ui::AccordionComponent.new) do |c|
      c.with_item(title: "Item 1", key: "item-1") { "Panel 1" }
    end

    trigger = page.find("button[data-accordion-target='trigger'][data-key='item-1']")
    panel = page.find("div[data-accordion-target='panel'][data-key='item-1']", visible: :all)

    assert_equal panel[:id], trigger["aria-controls"]
    assert panel[:id].present?
  end
end
