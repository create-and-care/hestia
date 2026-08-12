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
    assert_selector "p.font-display", text: "No items"
    assert_selector "p.text-secondary", text: "Add your first item to get started"
    assert_selector "div.mt-3", text: "Add item"
  end

  # The title is one of the three call sites that carry --font-display, and the
  # face is the point of the slot: an empty state addresses a person. It also
  # must not ask for a weight the single-weight serif cannot render — a
  # font-semibold here would be a synthetic bold on screen.
  test "the title carries the editorial serif at its only weight" do
    render_inline(Ui::EmptyComponent.new) { |c| c.with_title { "Aucune dépense pour l'instant" } }

    assert_selector "p.font-display.text-xl.font-normal", text: "Aucune dépense pour l'instant"
    refute_selector "p.font-semibold"
    refute_selector "p.font-medium"
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
