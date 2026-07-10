require "test_helper"

class Ui::BubbleComponentTest < ViewComponent::TestCase
  test "defaults to the assistant variant, left-aligned" do
    render_inline(Ui::BubbleComponent.new) { "Bonjour !" }

    assert_selector "div.mr-auto.bg-surface.text-primary.border.border-primary", text: "Bonjour !"
    assert_no_selector "div.ml-auto"
  end

  test "renders the user variant, right-aligned" do
    render_inline(Ui::BubbleComponent.new(variant: :user)) { "Salut !" }

    assert_selector "div.ml-auto.bg-button-primary.text-inverse", text: "Salut !"
    assert_no_selector "div.mr-auto"
  end

  test "raises for an unknown variant" do
    assert_raises(KeyError) do
      render_inline(Ui::BubbleComponent.new(variant: :system)) { "?" }
    end
  end
end
