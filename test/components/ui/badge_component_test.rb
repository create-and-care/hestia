require "test_helper"

class Ui::BadgeComponentTest < ViewComponent::TestCase
  test "renders default variant" do
    render_inline(Ui::BadgeComponent.new) { "New" }

    assert_selector "span.bg-button-primary", text: "New"
  end

  test "renders every variant with a distinguishing class fragment" do
    Ui::BadgeComponent::VARIANTS.each_key do |variant|
      render_inline(Ui::BadgeComponent.new(variant: variant)) { "Label" }

      assert_selector "span", text: "Label"
      assert_selector "span", class: fragment_for(variant)
    end
  end

  test "merges custom html_options including class and id" do
    render_inline(Ui::BadgeComponent.new(html_options: { id: "my-badge", class: "extra-class" })) { "Tag" }

    assert_selector "span#my-badge.extra-class.bg-button-primary", text: "Tag"
  end

  private

  def fragment_for(variant)
    {
      default: "bg-button-primary",
      secondary: "bg-surface-inset",
      outline: "bg-transparent",
      accent: /bg-accent/,
      success: /bg-success/,
      warning: /bg-warning/,
      urgent: /bg-orange/,
      destructive: /bg-destructive/
    }.fetch(variant)
  end
end
