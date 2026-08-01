require "test_helper"

class Ui::ModuleMedallionComponentTest < ViewComponent::TestCase
  test "renders the icon tinted with the module's accent" do
    render_inline(Ui::ModuleMedallionComponent.new(mod: :courses, icon: "shopping-cart"))

    assert_selector "span.bg-module-courses\\/12.text-module-courses"
    assert_selector "span[aria-hidden='true'][style*='mask']"
  end

  test "sizes map to the SIZES scale" do
    render_inline(Ui::ModuleMedallionComponent.new(mod: :fridge, icon: "refrigerator", size: :lg))

    assert_selector "span.size-16"
  end

  test "raises for an unknown module" do
    assert_raises(ArgumentError) do
      Ui::ModuleMedallionComponent.new(mod: :nonexistent, icon: "house")
    end
  end
end
