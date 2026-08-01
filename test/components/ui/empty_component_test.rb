require "test_helper"

class Ui::EmptyComponentTest < ViewComponent::TestCase
  test "renders all slots" do
    render_inline(Ui::EmptyComponent.new) do |c|
      c.with_icon { "ICON" }
      c.with_title { "No items" }
      c.with_description { "Add your first item to get started" }
      c.with_action { "Add item" }
    end

    assert_selector "div.border-dashed"
    assert_selector "p.font-medium", text: "No items"
    assert_selector "p.text-secondary", text: "Add your first item to get started"
    assert_selector "div.mt-3", text: "Add item"
  end

  test "renders nothing beyond the container when no slots are given" do
    render_inline(Ui::EmptyComponent.new)

    assert_selector "div.border-dashed"
    refute_selector "p"
    refute_selector "div.mt-3"
  end

  test "illustration slot takes precedence over icon when both are given" do
    render_inline(Ui::EmptyComponent.new) do |c|
      c.with_illustration { "<svg data-testid='illustration'></svg>".html_safe }
      c.with_icon { "ICON" }
    end

    assert_selector "svg[data-testid='illustration']"
    refute_text "ICON"
  end
end
