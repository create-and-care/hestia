require "test_helper"

class Ui::ViewToggleComponentTest < ViewComponent::TestCase
  test "renders a list and a grid link built from path_for" do
    render_inline(Ui::ViewToggleComponent.new(mode: "list", path_for: ->(mode) { "/things?view=#{mode}" }))

    assert_selector "div[role='group']"
    assert_selector "a[href='/things?view=list']"
    assert_selector "a[href='/things?view=grid']"
  end

  test "highlights the active mode" do
    render_inline(Ui::ViewToggleComponent.new(mode: "grid", path_for: ->(mode) { "/things?view=#{mode}" }))

    assert_selector "a[href='/things?view=grid'][aria-label='#{I18n.t('common.view_mode.grid')}']"
  end

  test "container_classes returns list classes by default and grid classes for grid" do
    assert_equal Ui::ViewToggleComponent::CONTAINER_CLASSES["list"], Ui::ViewToggleComponent.container_classes("list")
    assert_equal Ui::ViewToggleComponent::CONTAINER_CLASSES["grid"], Ui::ViewToggleComponent.container_classes("grid")
    assert_equal Ui::ViewToggleComponent::CONTAINER_CLASSES["list"], Ui::ViewToggleComponent.container_classes("unknown")
  end
end
