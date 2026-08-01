require "test_helper"

class Ui::HouseholdHeaderComponentTest < ViewComponent::TestCase
  test "renders the household name and note" do
    render_inline(Ui::HouseholdHeaderComponent.new(name: "Foyer Dupont", note: "4 membres"))

    assert_selector "h2", text: "Foyer Dupont"
    assert_selector "p", text: "4 membres"
  end

  test "renders fallback text when no photo slot is given" do
    render_inline(Ui::HouseholdHeaderComponent.new(name: "Foyer Dupont"))

    assert_text "Ajoutez une photo du foyer"
  end

  test "renders the photo slot instead of the fallback when given" do
    render_inline(Ui::HouseholdHeaderComponent.new(name: "Foyer Dupont")) { |c| c.with_photo { "<img alt=\"Foyer\">".html_safe } }

    assert_selector "img[alt='Foyer']"
    refute_text "Ajoutez une photo du foyer"
  end

  test "renders member avatars via AvatarGroup when members are given" do
    render_inline(Ui::HouseholdHeaderComponent.new(name: "Foyer Dupont", members: [ { alt: "Jane Doe" }, { alt: "John Doe" } ]))

    assert_selector "[data-controller='tooltip']", count: 2
  end

  test "renders the action slot when given" do
    render_inline(Ui::HouseholdHeaderComponent.new(name: "Foyer Dupont")) { |c| c.with_action { "Modifier" } }

    assert_selector "div", text: "Modifier"
  end
end
