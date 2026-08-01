require "test_helper"

class Ui::CelebrationMomentComponentTest < ViewComponent::TestCase
  test "renders the title, note, and the birthday medallion by default" do
    render_inline(Ui::CelebrationMomentComponent.new(title: "L'anniversaire de Camille approche", note: "Dans 3 jours"))

    assert_selector "p.font-hand", text: "L'anniversaire de Camille approche"
    assert_selector "p", text: "Dans 3 jours"
    assert_selector "span.bg-module-gifts\\/12"
  end

  test "maps kind to the right module and icon" do
    render_inline(Ui::CelebrationMomentComponent.new(kind: :streak, title: "7 jours de suite !"))
    assert_selector "span.bg-module-courses\\/12"

    render_inline(Ui::CelebrationMomentComponent.new(kind: :milestone, title: "100 repas planifiés"))
    assert_selector "span.bg-module-calendar\\/12"
  end

  test "is dismissible and exposes an accessible close button" do
    render_inline(Ui::CelebrationMomentComponent.new(title: "Bravo !"))

    assert_selector "[data-controller='dismiss']"
    assert_selector "button[data-action='click->dismiss#dismiss'][aria-label]"
  end

  test "renders the action slot when given" do
    render_inline(Ui::CelebrationMomentComponent.new(title: "Bravo !")) { |c| c.with_action { "Voir" } }

    assert_selector "div", text: "Voir"
  end
end
