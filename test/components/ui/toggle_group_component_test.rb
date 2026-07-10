require "test_helper"

class Ui::ToggleGroupComponentTest < ViewComponent::TestCase
  test "renders a group with a toggle button per item" do
    items = [ [ "Bold", "bold", false ], [ "Italic", "italic", false ] ]
    render_inline(Ui::ToggleGroupComponent.new(items: items))

    assert_selector "div[role='group'][data-controller='toggle-group']"
    assert_selector "button[data-toggle-group-target='item']", count: 2
  end

  test "marks pressed items with aria-pressed true and others false" do
    items = [ [ "Bold", "bold", true ], [ "Italic", "italic", false ] ]
    render_inline(Ui::ToggleGroupComponent.new(items: items))

    assert_selector "button[data-value='bold'][aria-pressed='true']", text: "Bold"
    assert_selector "button[data-value='italic'][aria-pressed='false']", text: "Italic"
  end

  test "defaults to single-select (multiple false)" do
    items = [ [ "Bold", "bold", false ] ]
    render_inline(Ui::ToggleGroupComponent.new(items: items))

    assert_selector "div[data-toggle-group-multiple-value='false']"
  end

  test "supports multiple selection mode" do
    items = [ [ "Bold", "bold", true ], [ "Italic", "italic", true ] ]
    render_inline(Ui::ToggleGroupComponent.new(items: items, multiple: true))

    assert_selector "div[data-toggle-group-multiple-value='true']"
    assert_selector "button[aria-pressed='true']", count: 2
  end

  test "renders a hidden input with the joined pressed values when name is given" do
    items = [ [ "Bold", "bold", true ], [ "Italic", "italic", true ], [ "Underline", "underline", false ] ]
    render_inline(Ui::ToggleGroupComponent.new(items: items, multiple: true, name: "formatting"))

    assert_selector "input[type='hidden'][name='formatting'][data-toggle-group-target='input'][value='bold,italic']", visible: :all
  end

  test "omits the hidden input when no name is given" do
    items = [ [ "Bold", "bold", false ] ]
    render_inline(Ui::ToggleGroupComponent.new(items: items))

    refute_selector "input[data-toggle-group-target='input']"
  end
end
