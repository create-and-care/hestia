require "test_helper"

class Ui::MarkerComponentTest < ViewComponent::TestCase
  test "renders default variant dot with no label" do
    render_inline(Ui::MarkerComponent.new)

    assert_selector "span.bg-button-primary"
    assert_no_selector "span.animate-ping"
  end

  test "renders every variant with its distinguishing class" do
    Ui::MarkerComponent::VARIANTS.each_key do |variant|
      render_inline(Ui::MarkerComponent.new(variant: variant, label: "Status"))

      fragment = Ui::MarkerComponent::VARIANTS.fetch(variant)
      assert_selector "span.#{fragment}"
    end
  end

  test "renders the label text when given" do
    render_inline(Ui::MarkerComponent.new(label: "Online"))

    assert_selector "span", text: "Online"
  end

  test "omits label text when not given" do
    render_inline(Ui::MarkerComponent.new)

    assert_no_text "Online"
  end

  test "renders a pulsing ping element when pulse is true" do
    render_inline(Ui::MarkerComponent.new(pulse: true))

    assert_selector "span.animate-ping"
  end

  test "omits the ping element when pulse is false" do
    render_inline(Ui::MarkerComponent.new(pulse: false))

    assert_no_selector "span.animate-ping"
  end
end
